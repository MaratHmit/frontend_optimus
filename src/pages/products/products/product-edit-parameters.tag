| import 'pages/products/parameters/feature-new-edit-modal.tag'
product-edit-parameters
    .row
        .col-md-12
            catalog-static(name='{ opts.name }', add='{ addParameters }', handlers='{ parametersHandlers }',
            cols='{ parametersCols }', rows='{ value }', responsive='false', remove='true')
                #{'yield'}(to='toolbar')
                    #{'yield'}(from='toolbar')
                #{'yield'}(to='body')
                    datatable-cell(name='name') { row.name }
                    datatable-cell(name='value')
                        input.form-control(if='{ row.type == "number" }', value='{ row.valueNumber }', type='number', min='0.00',
                        oninput='{ handlers.changeValue }')
                        i.fa.fa-fw(if='{ row.type == "bool" }', onclick='{ handlers.toggleCheckbox }',
                        class='{ row.valueBool ? "fa-check-square-o" : "fa-square-o" }')
                        input.form-control(if='{ row.type == "string" }', value='{ row.valueString }', type='text',
                        oninput='{ handlers.changeValue }')
                        autocomplete(if='{ row.type == "colorlist" }', load-data='{ handlers.getOptions(row.idFeature) }',
                        value='{ row.idValue }', value-field='value', id-field='id', onchange='{ handlers.changeColorValue }')
                            i.color(style='background-color: \#{ item.color };')
                            | &nbsp;&nbsp;{ item.value }
                        autocomplete(if='{ row.type == "list" }', load-data='{ handlers.getOptions(row.idFeature) }',
                        value='{ row.idValue }', text='{ row.resvalue }',
                        value-field='value', id-field='id',
                        onchange='{ handlers.changeColorValue }',
                        add='{ handlers.addParam}')
                            | { item.value }
                    datatable-cell(name='modificationId')
                        select.form-control(name='idModification', value='{ row.idModification}', onchange='{ handlers.changeselect }')
                            option(value='') Для всех
                            optgroup(each='{ mod in parent.parent.parent.parent.modifications }', label='{ mod.name }')
                                option(each='{ mi in mod.items }', value='{ mi.id }', selected='{row.idModification==mi.id}',  no-reorder) { mi.values[0].value }


    script(type='text/babel').
        var self = this
        self.modifications = []

        Object.defineProperty(self.root, 'value', {
            get() {
                return self.value || []
            },
            set(value) {
                self.value = value || []
                self.update()
            }
        })

        self.parametersCols = [
            {name: 'name', value: 'Наименование'},
            {name: 'value', value: 'Значение'},
            {name: 'modificationId', value: 'Модификация'},
        ]

        self.addParameters = e => {
            modals.create('parameters-list-select-modal', {
                type: 'modal-primary',
                size: 'modal-lg',
                submit() {
                    self.value = self.value || []

                    let items = this.tags.catalog.tags.datatable.getSelectedRows()

                    let ids = self.value.map(item => {
                        return item.idFeature
                    })

                    items.forEach(function (item) {
                      //  if (ids.indexOf(item.id) === -1) {
                            self.value.push({
                                idFeature: item.id,
                                name: item.name,
                                type: item.type
                            })
                        //}
                    })



                    let event = document.createEvent('Event')
                    event.initEvent('change', true, true)
                    self.root.dispatchEvent(event)

                    self.update()
                    this.modalHide()
                }
            })
        }
        console.log(opts)
        // Параметры Обработчики
        self.parametersHandlers = {
            getOptions(id) {
                var id = id
                return function () {
                    var _this = this
                    return API.request({
                        object: 'FeatureValue',
                        method: 'Fetch',
                        data: {filters: {field: 'idFeature', value: id}},
                        success(response) {
                            _this.data = response.items
                            if (!_this.isOpen) {
                                _this.data.forEach(item => {
                                    if (item[_this.idField] == _this.opts.value) {
                                        _this.filterValue = item[_this.valueField]
                                    }
                                })
                            }
                            _this.update()
                        }
                    })
                }
            },
            // переключатель
            toggleCheckbox(e) {
                this.row.valueBool = !this.row.value
            },
            // изменить значение
            changeValue(e) {
                if (e.target.type == '' || e.target.type == 'text') {
                    var selectionStart = e.target.selectionStart
                    var selectionEnd = e.target.selectionEnd
                    this.row.valueString = e.target.value
                    this.update()
                    e.target.selectionStart = selectionStart
                    e.target.selectionEnd = selectionEnd
                } else
                if (e.target.type == 'number')
                {
                    this.row.valueNumber = e.target.value
                    this.update()
                } else
                // если тип цели bool...
                if (e.target.type == 'bool')
                {
                    this.row.valueBool = e.target.value
                    this.update()
                }

            },
            changeColorValue(e) {
                this.row.idValue = this.row.valueIdList = e.target.value
                //console.log(e.target)
            },
            changeListValue(e) {
                this.row.idValue = this.row.valueIdList = e.target.value
            },
            modifications: self.modifications,
            changeselect(e) {
                e.item.row.idModification = e.target.value
            },
            addParam(e) {
                //console.log(this)
                var pthis = this,
                idFeature = pthis.parent.row.idFeature,
                idValue = pthis.parent.row.idValue,
                data = pthis.data,
                itemval = [],
                f = false

                itemval.value = this.filterValue || ''
                data.forEach(item=>{
                    if (item.value == itemval.value) {
                        pthis.parent.row.idValue = item.id
                        pthis.opts.value = item.id
                        pthis.parent.row.value = itemval.value
                        pthis.value = item.id
                        f = true
                        //self.update()
                        return
                    }
                })
                if (f) return;

                modals.create('feature-new-edit-modal', {
                    type: 'modal-primary',
                    typeparam: pthis.type,
                    item: itemval,
                    submit() {
                        var _this = this,
                        params = {}

                        _this.error = _this.validation.validate(_this.item, _this.rules)
                        data.forEach(item=>{
                            if (item.value == _this.item.value) {
                                _this.error = true
                            }
                        })

                        if (!_this.error ) {
                            params.idFeature = idFeature
                            params.value = _this.item.value
                            params.image = _this.item.image
                            params.color = _this.item.color
                            params.code = _this.item.code


                            API.request({
                                object: 'FeatureValue',
                                method: 'Save',
                                data: params,
                                success(response) {
                                    pthis.parent.row.idValue = response.id
                                    pthis.value = response.id
                                    pthis.opts.value = response.id
                                    pthis.parent.row.value = itemval.value
                                    data.push(response)
                                    _this.modalHide()
                                }
                            })
                        }
                    }
                })
            }
        }

        self.on('update', () => {
            if ('value' in opts)
                self.value = opts.value || []

            if ('modifications' in opts)
                self.modifications = opts.modifications || []

            if ('name' in opts)
                self.root.name = opts.name
        })

