| import debounce from 'lodash/debounce'
image-gallery
    .col-sm-6
        .form-inline
            .input-group(class='btn btn-primary btn-file', if='{ checkPermission("images", "0100") }')
                input(id="importFile", name='files', onchange='{ upload }', type='file', multiple='multiple', accept='image/*')
                i.fa.fa-plus
                |  Добавить
            button.btn.btn-danger(if='{ selectedCount && checkPermission("images", "0001") }', onclick='{ remove }', title='Удалить', type='button')
                i.fa.fa-trash
            button.btn.btn-danger(if='{ !opts.hideUnised checkPermission("images", "0001") }', onclick='{ removeUnused }', type='button')
                i.fa.fa-trash
                |  Удалить неиспользуемые
    .col-sm-6
        form.form-inline.text-right.m-b-2
            .form-group
                .input-group
                    input.searchCatalog.form-control(name='search', type='text', title='Поиск (Ctrl+F)', placeholder='Поиск', onkeyup='{ find }')
                    span.input-group-btn
                        button.btn.btn-default(onclick='{ find }', type='submit')
                            i.fa.fa-search

    .table-responsive.col-sm-12
        datatable(cols='{ cols }', rows='{ items }', handlers='{ handlers }', dblclick='{ opts.dblclick }')
            datatable-cell(name='')
                div.image-prev
                    img(src='{ handlers.getImageUrl(row.name) }', width='64')
            datatable-cell(name='name') { row.name }
            datatable-cell(name='sizeDisplay') { row.sizeDisplay }
            datatable-cell(name='weight') { row.weight }

    bs-pagination(name='paginator', onselect='{ pages.change }', pages='{ pages.count }', page='{ pages.current }')

    style.
        .image-prev {
            border-width: 1px;
            border-color: #F2F2F2;
            border-style: solid;
            display: -webkit-box;
            display: -webkit-flex;
            display: -ms-flexbox;
            display: flex;
            -webkit-align-items: center;
            -webkit-box-align: center;
            -ms-flex-align: center;
            align-items: center;
            -webkit-flex: auto;
            -ms-flex: auto;
            -webkit-box-flex: 1;
            flex: auto;
            width: 64px;
            height: 64px;
            overflow: hidden;
            -moz-border-radius: 4px;
            -webkit-border-radius: 4px;
            border-radius: 4px;
        }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')

        self.cols = [
            {name: '', value: 'Картинка'},
            {name: 'name', value: 'Наименование'},
            {name: 'sizeDisplay', value: 'Размер (px)'},
            {name: 'weight', value: 'Вес (байт)'},
        ]

        self.handlers = {
            getImageUrl: function (name) {
                if ((name.indexOf('http://') == -1) && (name.indexOf('https://') == -1)) {
                    return app.getImagePreviewURL(name, self.params.section)
                    //return app.config.imagePreviewURL + self.params.section + '/' + name
                } else {
                    return name
                }
            }
        }

        self.find = debounce(function(e) {
            if(e.key !== 'Control' && (e.key !== 'f' || (self.lastEvent !== 1)) ){
                if (self.pages.current > self.pages.count) self.pages.current = 1;
                self.reload();
                self.lastEvent = 0
            }
        }, 400)

        self.items = []
        self.params = {}

        self.pages = {
            count: 0,
            current: 1,
            limit: 11,
            change: function (e) {
                self.pages.current = e.currentTarget.page
                self.params.limit = self.pages.limit
                self.params.offset = (self.pages.current - 1) * self.pages.limit
                if (self.params.offset < 0)
                    self.params.offset = 0
                observable.trigger('images-page-change', self.params)
                self.reload()
            }
        }

        self.reload = function () {
            if (self.params.limit && self.params.offset)
                self.pages.current = (self.params.offset / self.params.limit) + 1
            if (self.search) {
                self.params.searchText = self.search.value
            }


            API.request({
                object: 'Image',
                method: 'Fetch',
                data: self.params,
                success(response) {
                    self.pages.count = Math.ceil(response.count / self.pages.limit)
                    if (self.pages.current > self.pages.count) {
                        self.pages.current = self.pages.count
                    }
                    self.items = response.items
                    self.tags.paginator.update({pages: self.pages.count, page: self.pages.current})
                    self.update()
                },
                error(response) {
                    self.pages.count = 1
                    self.pages.current = 1
                    self.items = []
                    self.tags.paginator.update({pages: self.pages.count, page: self.pages.current})
                    self.update()
                }
            })
        }

        self.removeUnused = function (e) {

            API.request({
                object: 'Image',
                method: 'Delete',
                data: {isUnused: true, section: self.params.section},
                success(response) {
                    popups.create({title: 'Успех!', text: 'Неиспользованные картинки удалены', style: 'popup-success'})
                    self.reload()
                }
            })
        }

        self.remove = function (e) {
            modals.create('bs-alert', {
                type: 'modal-danger',
                title: 'Предупреждение',
                text: 'Вы точно хотите удалить выделенные картинки?',
                size: 'modal-sm',
                buttons: [
                    {action: 'yes', title: 'Удалить', style: 'btn-danger'},
                    {action: 'no', title: 'Отмена', style: 'btn-default'},
                ],
                callback: function (action) {
                    if (action === 'yes') {
                        var files = self.tags.datatable.getSelectedRows().map(function (item) {
                            return item.name
                        })

                        var params = {
                            section: self.params.section,
                            files: files
                        }

                        API.request({
                            object: 'Image',
                            method: 'Delete',
                            data: params,
                            success(response) {
                                self.selectedCount = 0
                                self.reload()
                                popups.create({style: 'popup-success', title: 'Успех!', text: 'Удалено'})
                            }
                        })
                    }
                    this.modalHide()
                }
            })
        }

        self.upload = function (e) {
            var formData = new FormData();
            var items = []

            for (var i = 0; i < e.target.files.length; i++) {
                formData.append('file' + i, e.target.files[i], e.target.files[i].name)
                items.push(e.target.files[i].name)
            }

            API.upload({
                section: self.params.section,
                count: e.target.files.length,
                data: formData,
                success(response) {
                    items.forEach(function (item) {
                        self.items = [...response.items, ...self.items]
                    })

                    self.update()

                    if (typeof(opts.autoselect) === 'function') {
                        opts.autoselect.bind(self)(response.items[0])
                    }
                }
            })
            $("#importFile").val(undefined)
        }

        self.one('updated', function () {
            self.tags.datatable.on('row-selected', function (count) {
                self.selectedCount = count
                self.update()
            })
        })