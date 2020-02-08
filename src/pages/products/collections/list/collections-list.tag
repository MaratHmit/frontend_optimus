| import 'components/catalog.tag'
| import 'pages/products/collections/list/collections-list-card.tag'

collections-list
    catalog(
        name      = 'Collection',
        object    = 'Collection',
        cols      = '{ cols }',
        search    = 'true',
        allselect = 'true',
        reorder   = 'true',
        handlers  = '{ handlers }',
        reload    = 'true', store='parameters-list',
        filters   = '{ opts.filters }',
        add       = '{ permission(addEdit, "products", "0100") }',
        remove    = '{ permission(remove, "products", "0001") }',
        dblclick  = '{ permission(addEdit, "products", "1000") }'
    )
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='isActive', style="max-width: 50px;")
                button.btn.btn-default.btn-sm(type='button',
                    onclick='{ handlers.permission(handlers.boolChange, "products", "0010") }',
                    ontouchend='{ handlers.permission(handlers.boolChange, "products", "0010") }',
                    ontouchstart='{ stopPropagation }',
                    disabled='{ !handlers.checkPermission("products", "0010") }')
                    i(class='fa { row.isActive ? "fa-eye text-active" : "fa-eye-slash text-noactive" } ')
            datatable-cell(name='name') { row.name }
            datatable-cell(name='groupName') { row.groupName }
            datatable-cell(name='description') { row.description }


    script(type='text/babel').
        var self = this
        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Collection'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'isActive', value: 'Вид'},
            {name: 'name', value: 'Наименование'},
            {name: 'groupName', value: 'Категория'},
            {name: 'description', value: 'Описание'},
        ]

        self.addEdit = e => {
            let id
            if (e.item && e.item.row) {
                id = e.item.row.id
            }

            var idGroup = 0
            if (opts.filters !== undefined && opts.filters.length) {
                idGroup = opts.filters[0].value
            }

            modals.create('collections-list-card', {
                type: 'modal-primary',
                id: id,
                option: idGroup,
                submit() {
                var _this = this
                var params = _this.item
                _this.error = _this.validation.validate(_this.item, _this.rules)

                if (!_this.error) {
                        API.request({
                            object: 'Collection',
                            method: 'Save',
                            data: params,
                            success(response) {
                                self.tags['Collection'].reload();
                                _this.modalHide()
                            }
                        })
                    }
                }
            })
        }

         self.one('updated', () => {
            self.tags.catalog.tags.datatable.on('reorder-end', () => {
                let {current, limit} = self.tags.catalog.pages
                let params = { indexes: [] }
                let offset = current > 0 ? (current - 1) * limit : 0

                self.tags.catalog.items.forEach((item, sort) => {
                    item.sort = sort + offset
                    params.indexes.push({id: item.id, sort: sort + offset})
                })

                API.request({
                    object: 'Collection',
                    method: 'Sort',
                    data: params,
                    notFoundRedirect: false
                })

                self.update()
            })
        })