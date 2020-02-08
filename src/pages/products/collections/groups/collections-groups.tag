| import 'components/catalog.tag'
| import 'pages/products/collections/groups/collections-groups-card.tag'

collections-groups

    catalog(
        object    = 'CollectionGroup',
        cols      = '{ cols }',
        search    = 'true',
        add       = '{ permission(addEdit , "products", "0100") }',
        remove    = '{ permission(remove, "products", "0001") }',
        dblclick  = '{ permission(addEdit, "products", "1000") }',
        reorder   = 'true',
        reload    = 'true',
        handlers  = '{ handlers }',
        store     = 'collections-groups-list'
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
            datatable-cell(name='price', style="max-width: 100px;")
                span  { (row.price / 1).toFixed(2) }
                span(style='color: #ccc')  ₽
            datatable-cell(name='description') { row.description }

    style(scoped).
        .table td {
            vertical-align: middle !important;
        }

    script(type='text/babel').

        let self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'CollectionGroup'

        self.cols = [
            {name: 'id', value: '#', width: '50px'},
            {name: 'isActive', value: 'Вид'},
            {name: 'name', value: 'Наименование' },
            {name: 'price', value: 'Цена'},
            {name: 'description', value: 'Описание'},
        ]

        self.addEdit = e => {
            let id
            if (e.item && e.item.row) {
                id = e.item.row.id
            }

            modals.create('collections-groups-card', {
                type: 'modal-primary',
                id: id,
                submit() {
                    var _this = this
                    var params = _this.item

                    _this.error = _this.validation.validate(_this.item, _this.rules)

                    if (!_this.error) {
                        API.request({
                            object: 'CollectionGroup',
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

        self.handlers = {
            checkPermission: self.checkPermission,
            permission: self.permission,
            boolChange(e) {
                let _this = this
                e.stopPropagation()
                e.stopImmediatePropagation()

                _this.row[_this.opts.name] = _this.row[_this.opts.name] ? 0 : 1

                let params = {}
                params.id = _this.row.id
                params[_this.opts.name] = _this.row[_this.opts.name]

                API.request({
                object: 'CollectionGroup',
                    method: 'Save',
                    data: params,
                    error(response) {
                        _this.row[_this.opts.name] = _this.row[_this.opts.name] ? 0 : 1
                        self.update()
                    }
                })
            }
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
                    object: 'CollectionGroup',
                    method: 'Sort',
                    data: params,
                    notFoundRedirect: false
                })

                self.update()
            })
        })

        observable.on('collections-groups-reload', () => {
            self.tags.catalog.reload()
        })