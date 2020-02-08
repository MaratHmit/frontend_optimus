| import 'components/catalog.tag'

projects-groups
    catalog(
        search    = 'true',
        sortable  = 'true',
        object    = 'Brand',
        cols      = '{ cols }',
        reorder   = 'true',
        allselect = 'true',
        reload    = 'true',
        store     = 'brands-list',
        add       = '{ permission(add, "products", "0100") }',
        remove    = '{ permission(remove, "products", "0001") }',
        dblclick  = '{ permission(brandOpen, "products", "1000") }'
    )
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='img')
                img(if='{ row.imageUrlPreview.trim() !== "" }', src='{ row.imageUrlPreview }', style='max-width: 200px;')
            datatable-cell(name='name') { row.name }
            datatable-cell(name='code') { row.code }

    style(scoped).
        .table td {
            vertical-align: middle !important;
        }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Brand'

        self.cols = [
            {name: 'id', value: '#', width: '50px'},
            {name: 'img', value: 'Логотип'},
            {name: 'name', value: 'Наименование' },
            {name: 'code', value: 'URL' },
        ]

