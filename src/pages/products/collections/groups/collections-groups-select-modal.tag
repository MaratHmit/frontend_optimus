collections-groups-select-modal.tag
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Группы коллекций
        #{'yield'}(to="body")
            catalog(object='CollectionGroup', cols='{ parent.cols }', reload='true',
            dblclick='{ parent.opts.submit.bind(this) }', handlers='{ parent.handlers }')
                #{'yield'}(to='body')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='name') { row.name }
                    datatable-cell(name='price', style="max-width: 100px;")
                                    span  { (row.price / 1).toFixed(2) }
                                    span(style='color: #ccc')  ₽
                    datatable-cell(name='description') { row.description }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').
        var self = this

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
            {name: 'price', value: 'Цена'},
            {name: 'description', value: 'Описание'},
        ]