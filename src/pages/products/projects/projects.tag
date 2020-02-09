| import 'pages/products/projects/projects-list.tag'
| import 'pages/products/projects/project-group-new-modal.tag'

projects
    .row
        .col-md-4.col-xs-12
            .well.well-sm
                .form-inline
                    .form-group
                        label.control-label Группы
            catalog(
                object      = 'ShopProjectGroup',
                cols        = '{ cols }',
                add         = '{ addEdit }',
                remove      = '{ remove }',
                dblclick    = '{ addEdit }',
                short       = 'true',
                reorder     = 'true',
                reload      = 'true',
                handlers    = '{ handlers }',
                disablepagination = 'true'
            )
                #{'yield'}(to='body')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='name') { row.name }

        .col-md-8.col-xs-12
            .well.well-sm
                .form-inline
                    .form-group
                        label.control-label Успешные проекты
            projects-list(name='section-item', filters='{ categoryFilters }', section='{ idSection }')

    script(type='text/babel').
        var self = this

        self.collection = 'ShopProjectGroup'
        self.idSection = 0;
        self.categoryFilters = [{field: 'idGroup', sign: 'IN', value: self.idGroup }]

        self.mixin('permissions')
        self.mixin('remove')

        var route = riot.route.create()

        self.addEdit = e => {
            var id
            if (e.item && e.item.row) {
                id = e.item.row.id
            }

            modals.create('project-group-new-modal', {
                type: 'modal-primary',
                id: id,
                submit() {
                    var _this = this
                    var params = _this.item

                    _this.error = _this.validation.validate(_this.item, _this.rules)

                    if (!_this.error) {
                        API.request({
                        object: 'ShopProjectGroup',
                            method: 'Save',
                            data: params,
                            success(response) {
                                _this.modalHide()
                                self.tags.catalog.reload()
                            }
                        })
                    }
                }
            })
        }

        self.cols = [
            { name: 'id', value: '#'},
            { name: 'name', value: 'Наименование'},
        ]

        self.one('updated', () => {
            self.tags.catalog.tags.datatable.on('reorder-end', () => {
                let {current, limit} = self.tags.catalog.pages
                let params = { indexes: [] }
                let offset = current > 0 ? (current - 1) : 0
                console.log(offset)

                self.tags.catalog.items.forEach((item, sort) => {
                    item.sort = sort + offset
                    params.indexes.push({id: item.id, sort: sort + offset})
                })

                API.request({
                    object: 'ShopProjectGroup',
                    method: 'Sort',
                    data: params,
                    notFoundRedirect: false
                })
                self.update()
            })
        })

        observable.on('projects-reload', () => {
            self.tags.catalog.reload()
        })


        self.pageclick = e => {
            let rows = self.tags['section-page'].tags.datatable.getSelectedRows()
            self.idSection = rows[0].idSection;
            self.categoryFilters = [{field: 'idSection', sign: 'IN', value: self.idSection }]
            self.update()
            observable.trigger('section-reload')
        }