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
                name        = 'ShopProjectGroup',
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
            projects-list(name='projectList', filters='{ projectsFilter }', section='{ idGroup }')

    script(type='text/babel').
        var self = this

        self.collection = 'ShopProjectGroup'
        self.idSection = 0;
        self.projectsFilter = false;

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

            var datatable = self.tags['ShopProjectGroup'].tags.datatable
            datatable.on('row-selected', (count, row) => {
                let items = datatable.getSelectedRows()
                if (items.length > 0) {
                    let value = items.map(i => i.id).join(',')
                    self.projectsFilter = [{field: 'idGroup', sign: 'IN', value}]
                    } else {
                        self.projectsFilter = false
                    }
                    self.update()
                    self.tags['projectList'].tags['ShopProject'].reload()
            })


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