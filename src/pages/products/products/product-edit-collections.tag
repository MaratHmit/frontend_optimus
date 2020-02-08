| import 'pages/products/collections/groups/collections-groups-select-modal.tag'

product-edit-collections
    .row.col-md-12
        catalog-static(name='{ opts.name }', add='{ add }',
            cols='{ cols }', rows='{ value }', handlers='{ handlers }', remove='true')
            #{'yield'}(to='toolbar')
                #{'yield'}(from='toolbar')

            #{'yield'}(to='body')
                datatable-cell(name='id') { row.id }
                datatable-cell(name='name') { row.name }
                datatable-cell(name='price')
                    input.form-control(type='number', min='0', step='10' value='{ row.price }', onchange='{ handlers.priceChange }')


    script(type='text/babel').
        var self = this

        Object.defineProperty(self.root, 'value', {
            get() {
                return self.value || []
            },
            set(value) {
                self.value = value || []
                self.update()
            }
        })

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
            {name: 'price', value: 'Цена'},
        ]

        self.add = () => {
            modals.create('collections-groups-select-modal', {
                type: 'modal-primary',
                size: 'modal-lg',
                submit() {
                    self.value = self.value || []

                    let items = this.tags.catalog.tags.datatable.getSelectedRows()

                    let ids = self.value.map(item => {
                        return item.id
                    })

                    items.forEach(item => {
                        if (ids.indexOf(item.id) === -1)
                            self.value.push(item)
                    })

                    let event = document.createEvent('Event')
                    event.initEvent('change', true, true)
                    self.root.dispatchEvent(event)

                    self.update()
                    this.modalHide()
                }
            })
        }

        self.handlers = {
            priceChange: function (e) {
                e.item.row.price = e.target.value
            },
        }

        self.on('update', () => {
            if ('name' in opts && opts.name !== '')
                self.root.name = opts.name

            if ('value' in opts)
                self.value = opts.value || []
        })