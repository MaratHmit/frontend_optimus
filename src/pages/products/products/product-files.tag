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
                    catalog-static(name='{ opts.name }', cols='{ cols }', rows='{ value }', handlers='{ handlers }',
                    catalog='{ catalog }', upload='{ upload }',  remove='{ handlers.remove }', reorder='true', nolimit='true',
                        afterRemove='{ after }')
                        #{'yield'}(to='toolbar')
                            .form-group(if='{ checkPermission("images", "1000") }')
                                .input-group(class='btn btn-primary btn-file')
                                    input(name='files', onchange='{ opts.upload }', type='file', multiple='multiple')
                                    i.fa.fa-plus
                                    |  Загрузить
                                button.btn.btn-default(name='link', onclick='{ parent.addLink }', type='button')
                                    i.fa.fa-plus
                                    |  Ссылку
                        #{'yield'}(to='body')
                            datatable-cell(name='', style='width: 30px;')
                                i.fa.fa-cloud-download.fa-2x
                            datatable-cell(name='')
                                input.form-control(value='{ row.fileText }', onchange='{ handlers.fileNameChange }')
                            datatable-cell(name='')
                                b.form-control-static { row.fileURL }
                            datatable-cell(name='')
                                b.form-control-static
                                    select.form-control(name='idGroup', onchange='{ handlers.changeCategory }')
                                        option(value='') Без группы
                                        option(each='{ handlers.filesCategory }', value='{ id }',
                                        selected='{ id == row.idGroup }', no-reorder) { name }

        #product-files-group.tab-pane.fade
            .row
                .col-md-12
                    files-categories-list(idProduct='{ idProduct }')

    script(type='text/babel').
        var self = this
        self.mixin('permissions')
        self.app = app
        self.filesCategory = []
        self.idProduct = 0
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
                e.item.row.fileText = e.target.value
            },
            changeCategory: function(e) {
                if (e.target.value == '')
                    e.item.row.idGroup = null
                else e.item.row.idGroup = e.target.value
            },
            remove: function (e) {
                var rows = self.tags['catalog-static'].tags.datatable.getSelectedRows()

                rows.forEach(function(row) {
                    self.value.splice(self.value.indexOf(row),1)
                })
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

        self.addLink = e => {
            modals.create('add-link-modal', {
                type: 'modal-primary',
                title: 'Добавить ссылку',
                submit() {
                    self.value.push({
                        fileText: this.item.name,
                        fileURL:  this.item.name,
                        fileExt:  'http',
                        fileName: this.item.name
                    })
                    let event = document.createEvent('Event')
                    event.initEvent('change', true, true)
                    self.root.dispatchEvent(event)

                    self.update()
                    this.modalHide()
                }
            })
        }

        self.upload = e => {
            var formData = new FormData();
            var FilesItems = []

            for (var i = 0; i < e.target.files.length; i++) {
                formData.append('file'+i, e.target.files[i], e.target.files[i].name)
                //items.push(e.target.files[i].name)
           }

           API.upload({
                section: opts.section,
                object: 'Files',
                count: e.target.files.length,
                data: formData,
                progress: function(e) {},
                success: function(response) {
                    FilesItems = response.items
                    self.value = self.value || []

                    if(FilesItems.length == 0){
                        popups.create({title: 'Ошибка!', text: 'Данные файлы уже есть на сервере', style: 'popup-danger'})
                    }
                    FilesItems.forEach(i => {
                        self.value.push({
                            fileText: i.name,
                            fileURL:  i.url,
                            fileExt:  i.ext,
                            fileName: i.file
                        })
                    })
                    let event = document.createEvent('Event')
                    event.initEvent('change', true, true)
                    self.root.dispatchEvent(event)
                    self.update()
                }
           })
        }

        self.on('updated', () => {

            self.tags['catalog-static'].tags.datatable.on('reorder-end', (newIndex, oldIndex) => {
            self.tags['catalog-static'].value.splice(newIndex, 0, self.tags['catalog-static'].value.splice(oldIndex, 1)[0])
                var temp = self.tags['catalog-static'].value
                self.rows = []
                self.update()
                self.tags['catalog-static'].value = temp
                self.tags['catalog-static'].items.forEach((item, sort) => {
                item.sortIndex = sort
                })
        })
        })

        self.after = (e) => {
            console.log("ok")
        }

        self.on('update', () => {
            if ('name' in opts && opts.name !== '')
                self.root.name = opts.name

            if ('value' in opts)
                self.value = opts.value || []
        })

        observable.on('product-files', id => {
            self.idProduct = id
            self.getCategoryes(id)
        })

