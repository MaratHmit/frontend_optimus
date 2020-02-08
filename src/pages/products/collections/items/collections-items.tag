| import 'components/catalog.tag'
| import 'pages/products/collections/items/collections-items-card.tag'

collections-items
    catalog(
        name      = 'CollectionItem',
        object    = 'CollectionItem',
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
            datatable-cell(name='image')
                img(if='{ row.imageUrlPreview.trim() !== "" }', src='{ row.imageUrlPreview }')
            datatable-cell(name='name') { row.name }
            datatable-cell(name='collectionName') { row.collectionName }

    script(type='text/babel').
        let self = this
        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'CollectionItem'

        self.addEdit = e => {
            let id
            if (e.item && e.item.row) {
                id = e.item.row.id
            }

            let idCollection = 0
            if (opts.filters !== undefined && opts.filters.length) {
                idCollection = opts.filters[0].value
            }

            modals.create('collections-items-card', {
                type: 'modal-primary',
                option: idCollection,
                id: id,
                submit() {
                    let _this = this
                    let params = _this.item
                    _this.error = _this.validation.validate(_this.item, _this.rules)

                     if (!_this.error) {
                        API.request({
                            object: 'CollectionItem',
                            method: 'Save',
                            data: params,
                            success(response) {
                                self.tags['CollectionItem'].reload();
                                _this.modalHide()
                            }
                        })
                    }
                }
            })
        }
        self.cols = [
            {name: 'id', value: '#'},
            {name: 'image', value: 'Фото'},
            {name: 'name', value: 'Наименование'},
            {name: 'collectionName', value: 'Коллекция'},
        ]


        self.one('updated', () => {
            self.tags['CollectionItem'].tags.datatable.on('reorder-end', () => {
                let {current, limit} = self.tags['CollectionItem'].pages
                let params = { indexes: [] }
                let offset = current > 0 ? (current - 1) * limit : 0

                self.tags['CollectionItem'].items.forEach((item, sort) => {
                    item.sort = sort + offset
                    params.indexes.push({id: item.id, sort: sort + offset})
                })

                API.request({
                    object: 'CollectionItem',
                    method: 'Sort',
                    data: params,
                    notFoundRedirect: false
                })

                self.update()
            })
        })