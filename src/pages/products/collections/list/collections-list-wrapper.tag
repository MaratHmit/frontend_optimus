| import 'components/catalog.tag'
| import 'pages/products/collections/list/collections-list-card.tag'
| import 'pages/products/collections/list/collections-list.tag'

collections-list-wrapper
    .row
        .col-md-4
            catalog(
                name      = 'CollectionGroup',
                object    = 'CollectionGroup',
                cols      = '{ colsOption }',
                handlers  = '{ handlers }'
                allselect = 'false',
                reload    = 'true',
                sortable  = 'false',
                reorder   = 'false',
                filters   = '{ categoryFilters }',
                add       = '{ false }',
                remove    = '{ false }',
                dblclick  = '{ false }'
            )
                #{'yield'}(to='filters')
                    .well.well-sm
                        .form-inline
                            .form-group
                                label.control-label Категории

                #{'yield'}(to='body')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='name') { row.name }

        .col-md-8.col-xs-12.col-sm-12
            collections-list(name='CollectionList', filters='{ collectionFilters }')

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Collection'
        self.optionFilters = false
        self.optionCategories = []
        self.categoryId = 0
        self.handlers = {  }

        self.colsOption = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
        ]

        self.one('updated', () => {
            var datatable = self.tags['CollectionGroup'].tags.datatable
            datatable.on('row-selected', (count, row) => {
                    let items = datatable.getSelectedRows()
                    if (items.length > 0) {
                        let value = items.map(i => i.id).join(',')
                        self.collectionFilters = [{field: 'idGroup', sign: 'IN', value}]
                    } else {
                        self.collectionFilters = false
                    }
                    self.update()
                    self.tags['CollectionList'].tags['Collection'].reload()
            })
            self.tags['CollectionGroup'].tags.datatable.on('reorder-end', () => {
                let {current, limit} = self.tags['option'].pages
                let params = { indexes: [] }
                let offset = current > 0 ? (current - 1) * limit : 0

                self.tags['option'].items.forEach((item, sort) => {
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

