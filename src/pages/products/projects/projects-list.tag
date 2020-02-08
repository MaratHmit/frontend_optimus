| import 'components/catalog.tag'


projects-list
    catalog(object='ShopProject',
        search='true',
        sortable='true',
        cols='{ cols }',
        reload='true',
        add='{ add }',
        remove='{ remove }',
        dblclick='{ open }',
        store='projects-list',
        new-filter='true')

        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='image')
                img(if='{ row.imageUrlPreview.trim() !== "" }', src='{ row.imageUrlPreview }')
            //datatable-cell(name='date') { row.date }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='text') { row.text }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'ShopProjects'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'image', value: 'Фото'},
            // {name: 'date', value: 'Дата'},
            {name: 'name', value: 'Наименование'},
            {name: 'text', value: 'Описание'},
        ]


        self.add = () => {
            if (self.selectedCategory)
                riot.route(`/news/new?category=${self.selectedCategory}&name=${self.selectedCategoryName}`)
            else
                riot.route('/products/projects/new')
        }

        self.open = e => {
            riot.route(`/products/projects/${e.item.row.id}`)
        }

        self.getProjectsCategories = () => {
            API.request({
                object: 'ShopProjectGroup',
                method: 'Fetch',
                success(response) {
                    self.projectsCategories = response.items
                    self.update()
                }
            })
        }

        self.selectCategory = e => {
            self.selectedCategory = e.target.value || undefined
            self.selectedCategoryName = ''
            self.newsCategories.forEach(function(item) {
                if (self.selectedCategory == item.id) {
                    self.selectedCategoryName = item.title
                }
            })
        }

        self.one('updated', () => {
            self.tags.catalog.on('reload', () => {
            self.getNewsCategories()
            })
        })

        observable.on('projects-reload', () => {
             self.tags.catalog.reload()
        })

        self.getProjectsCategories()


