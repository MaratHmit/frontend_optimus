| import 'components/catalog.tag'
| import 'pages/products/collections/items/collections-items.tag'
| import 'pages/products/collections/items/collections-items-card.tag'

collections-items-wrapper
    .row
        .col-md-4
            catalog(
                name      = 'Collection',
                object    = 'Collection',
                cols      = '{ colsOption }',
                handlers  = '{ handlers }'
                allselect = 'false',
                reload    = 'true',
                sortable  = 'false',
                reorder   = 'false',
                filters   = '{ collectionFilters }',
            )
                #{'yield'}(to='filters')
                    .well.well-sm
                        .form-inline
                            .form-group
                                label.control-label Категория:
                                select.form-control(data-name='idGroup', onclick='{ parent.selectCategory }')
                                    option(value='') Все
                                    option(each='{ category, i in parent.optionCategories }', value='{ category.id }', no-reorder) { category.name }


                #{'yield'}(to='body')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='name') { row.name }
                    datatable-cell(name='groupName') { row.groupName }

        .col-md-8.col-xs-12.col-sm-12
            collections-items(name='CollectionItems', filters='{ collectionItemFilters }')

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Collection'
        self.optionFilters = false
        self.optionCategories = []
        self.categoryId = 0

        self.colsOption = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Коллекция'},
            {name: 'groupName', value: 'Категория'},
        ]

        self.getCollectionGroup = () => {
            API.request({
            object: 'CollectionGroup',
            method: 'Fetch',
            success(response) {
                self.optionCategories = response.items
                self.update()
                }
            })
        }

        self.getCollectionGroup()

        self.one('updated', () => {
            var datatable = self.tags['Collection'].tags.datatable
            datatable.on('row-selected', (count, row) => {
                let items = datatable.getSelectedRows()
                if (items.length > 0) {
                    let value = items.map(i => i.id).join(',')
                    self.collectionItemFilters = [{field: 'idCollection', sign: 'IN', value}]
                } else {
                    self.collectionItemFilters = false
                }
                self.update()
                self.tags['CollectionItems'].tags['CollectionItem'].reload()
            })
        })


