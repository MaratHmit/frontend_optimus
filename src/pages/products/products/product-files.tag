| import 'components/datatable.tag'
| import 'components/catalog-static.tag'
| import 'modals/add-link-modal.tag'
| import 'pages/products/files/files-modal.tag'
| import 'pages/products/products/files/files-categories-list.tag'

product-files
    ul(if='{ !edit }').nav.nav-tabs.m-b-2
        li.active: a(data-toggle='tab', href='#product-files-list') Файлы
        li: a(data-toggle='tab', href='#product-files-group') Группы

    .tab-content
        #product-files-list.tab-pane.fade.in.active
            .row
                .col-md-12
                    catalog-static(name='{ opts.name }', cols='{ cols }', rows='{ items }', handlers='{ handlers }',
                    catalog='{ catalog }', upload='{ upload }', remove='true', reorder='true', nolimit='true')
                        #{'yield'}(to='toolbar')
                            .form-group(if='{ checkPermission("images", "1000") }')
                                button.btn.btn-primary(onclick='{ opts.catalog }', type='button')
                                    i.fa.fa-plus
                                    |  Добавить
                        #{'yield'}(to='body')
                            datatable-cell(name='', style='width: 30px;')
                                i.fa.fa-cloud-download.fa-2x
                            datatable-cell(name='')
                                input.form-control(value='{ row.name }', onchange='{ handlers.fileNameChange }')
                            datatable-cell(name='')
                                b.form-control-static { row.filePath }
                            datatable-cell(name='')
                                b.form-control-static
                                    select.form-control(name='idGroup', onchange='{ handlers.changeCategory }')
                                        option(value='') Без группы
                                        option(each='{ handlers.filesCategory }', value='{ id }',
                                        selected='{ id == row.idGroup }', no-reorder) { name }

        #product-files-group.tab-pane.fade
            .row
                .col-md-12
                    files-categories-list(idObject='{ idObject }')

    script(type='text/babel').
        var self = this
        self.mixin('permissions')
        self.app = app
        self.filesCategory = []
        self.idObject = 0
        self.items = []

        Object.defineProperty(self.root, 'value', {
            get() {
                return self.items
            },
            set(value) {
                self.items = value || []
                self.update()
            }
        })

        self.add = () => {}

        self.cols = [
            {name: '', value: ''},
            {name: '', value: 'Текст ссылки'},
            {name: '', value: 'Файл'},
            {name: '', value: 'Категория'},
        ]

        self.handlers = {
            fileNameChange: function (e) {
                e.item.row.name = e.target.value
            },
            changeCategory: function(e) {
                if (e.target.value == '')
                    e.item.row.idGroup = null
                else e.item.row.idGroup = e.target.value
            },
            filesCategory: []
        }

        self.getCategoryes = id => {
            API.request({
                object: 'FilesCategory',
                method: 'Fetch',
                success(response) {
                    self.handlers.filesCategory = response.items
                    self.update()
                }
            })
        }

        self.catalog = e => {
            modals.create('files-modal', {
                type: 'modal-primary',
                size: 'modal-lg',
                submit: function () {
                    let filemanager = this.tags.filemanager
                    let items = filemanager.getSelectedFiles()
                    let path = filemanager.path
                    let name = filemanager.name

                    items.forEach(item => {
                        self.items.push({
                            filePath: app.clearRelativeLink(`${path}/${item.name}`),
                            name: name
                        })
                    })

                    let event = document.createEvent('Event')
                    event.initEvent('change', true, true)
                    self.root.dispatchEvent(event)

                    self.update()
                    this.modalHide()
                }
            })
        }

        self.on('update', () => {
            if ('name' in opts && opts.name !== '')
                self.root.name = opts.name

            if ('value' in opts) {
                self.items = opts.value || []
            }
            if (self.items.length){
                self.value = []
                self.items.forEach(item => {
                    if (item.idGroup == self.idCategory) {
                        self.value.push(item)
                    }
                })

            }

        })

        observable.on('object-files', id => {
            self.idObject = id
            self.getCategoryes(id)
        })
