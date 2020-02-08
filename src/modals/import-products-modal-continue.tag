import-products-modal-continue
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Импорт (Шаг 2 из 2)
        #{'yield'}(to="body")
            // loader(text='Импорт', indeterminate='true', if='{ loader }')
            div(id="myProgress", style='width: 100%; background-color: #ccc;', if='{ loader }')
                div(id="myBar", style='width: 0%; height: 30px; background-color: #0782C1; text-align: center; line-height: 30px; color: white;') 0%
            div(id="terminalImp", style='width: 100%; margin-top: 20px; color: orange', if='{ loader }')
            form(onchange='{ change }', onkeyup='{ change }', if='{ !loader }')

                // Вывод всех столбцов
                .container-fluid
                    table.table.table.table
                        thead
                            tr
                                th #
                                th Пример
                                th Мод.
                                th Тип
                        tbody
                            tr(id='tbody',each='{ category, i in item[0] }')
                                td
                                    | { i }
                                td(style='width: 55%;')
                                    div(style='width: 180px; overflow: hidden;') { item[1][i] || 'Пустая строка' }
                                td
                                    div(id="mod{ i }", style='width: 100%;')
                                td(style='width: 35%')
                                    select.form-control(id='tbody{ i }',onchange='{ changeitem }', name='{ category }')
                                        option(value='{ i }:undefined:undefined')
                                        option(
                                            each='{ russian, english in item[2] }',
                                            selected='{ item[0][i] == russian }',
                                            value='{ i }:{ russian }:{ english }',
                                            no-reorder
                                        ) { russian }
                                    //.help-block(style='max-height:50px; text-overflow: ellipsis; overflow: hidden; max-width: 150px')
                                        b Пример: {' '}
                                        | { item[1][i] || 'Пустая строка' }

                    //- //.row(each='{ category, i in item[0] }')
                    //-     .form-group
                    //-         label.control-label Столбец { '#' + i }
                    //-         .col-sm-6
                    //-             | hghjgjhg
                    //-         .col-sm-6
                    //-             select.form-control
                    //-                 option(value='')
                    //-                 option(
                    //-                     each='{ russian, english in item[2] }',
                    //-                     selected='{ item[0][i] == russian }',
                    //-                     value='{ english }',
                    //-                     no-reorder
                    //-                 ) { russian }
                    //-         .help-block(style='max-height:50px; text-overflow: ellipsis; overflow: hidden;')
                    //-             b Пример: {' '}
                    //-             | { item[1][i] || 'Пустая строка' }

                .form-group
                    label.control-label Тип импорта
                    br
                    label.radio-inline
                        input(type='radio', name='type', value='0', checked='{ item.type == 0 }')
                        | Обновление
                    label.radio-inline
                        input(type='radio', name='type', value='1', checked='{ item.type == 1 }')
                        | Вставка
                .form-group(if='{ item.type == 1 }')
                    .checkbox-inline
                        label
                            input(name='reset', type='checkbox', checked='{ item.reset }', onchange='{ resetCheckbox }')
                            | Очистить базу данных перед импортом
            div(id="errorLabel", style='width: 100%; margin-top: 0px; color: #a94442', if='{ !loader }')
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed', disabled='{ cannotBeClosed }') Закрыть
            button(id='startImp', onclick='{ parent.submit }', type='button', class='btn btn-primary btn-embossed', disabled='{ cannotBeClosed }', if='{ !loader }') Импорт


    script(type='text/babel').
        var self = this
        var items = JSON.parse(localStorage.getItem('shop24_import_products') || '{}')
        localStorage.removeItem('shop24_import_products')

        self.item = items.prepare
        self.coincidence = false

        /** проверка наличия соотношений в профиле и замена (при положительном результате) */
        var profiles = JSON.parse(localStorage.getItem("profiles"))

        if (profiles[profiles['groupNow']]['margins'] != undefined) {
            var tmpprofile = profiles[profiles['groupNow']]['margins']
            if (tmpprofile.length == self.item[0].length) {
                self.item[0] = tmpprofile
            }
        }


        self.on('mount', () => {

            /**
             * прогрузка страницы
             * @metod {bool} comparisonValues - сверяет значения в таблице, при совпадении подсвечивает и блокирует кнопку импорта
             */

            let modal = self.tags['bs-modal']
            self.item.type = 0
            self.errorLabel = {}

            modal.error = false
            modal.mixin('validation')
            modal.mixin('change')
            modal.item = self.item

            /** сохранение и передача пользовательских правок */
            self.newItem = {
                'newTitele' : {},
                'newDB'     : {}
            }

            self.monitoring()

            modal.changeitem = e => {
                /**
                 * пользовательские замены
                 * @param {array}  num_walue_db - значения строки из динамического списка
                 * @param {int}    num          - номер строки в динамическом списке
                 * @param {string} walue        - имя столбца на русском (если пустое "undefined")
                 * @param {string} db           - имя столбца на латыни (если пустое "undefined")
                 */

                let num_walue_db = e.target.value.split(':')
                let num          = Number(num_walue_db[0])
                let walue        = num_walue_db[1]
                let db           = num_walue_db[2]

                self.newItem.newTitele[num] = walue
                self.newItem.newDB[e.target.name] = db

                self.comparisonValues()
            } // пользовательские замены

            modal.resetCheckbox = e => {
                if (self.item.reset != true) {
                    self.errorLabel.delete = 'ВНИМАНИЕ: будут удалены все данные по товарам и заказам!'
                    self.printErrorLabel()
                } else {
                    delete self.errorLabel.delete
                    self.printErrorLabel()
                }
            } // Очистить базу данных

        }) // прогрузка страницы

        self.monitoring = () => {
            if(document.getElementById('tbody')) {self.comparisonValues()}
            else {setTimeout(function()          {self.monitoring()}, 100)}
        } // ожидание, прослушивание элемента

        self.comparisonValues = () => {

            /**
             * сверка значений - проверка отсутствия совпадений и наличия ключевого поля
             * @param {array}  currentItem  - массив значений в интерфейсе
             * @param {str}    errorLabel   - строка ошибок для вывода на панель
             * @param {bool}   coincidence  - true найдено совпадение
             * @param {bool}   keyField     - false не найдено ключевое поле
             */

            var currentItem = {}
            for (let i = 0; i < self.item[0].length; i++) {
                if (i in self.newItem.newTitele) currentItem[i] = self.newItem.newTitele[i]
                else currentItem[i] = self.item[0][i]
            }

            /** проверка совпадений - обнаруженные подсветить, не обнаруженные погасить */
            self.coincidence = false
            self.keyField    = false
            for (var k1 in currentItem) {
                /** проверка совпадений */
                var coinUnit = false
                for (var k2 in currentItem) {
                    if (currentItem[k1] == currentItem[k2] && k1 != k2 && currentItem[k1] != 'undefined') {
                        document.getElementById("tbody" + k1).style.borderColor = "#a94442";
                        coinUnit = true
                        self.coincidence = true
                        break
                    }
                }
                if (coinUnit == false) document.getElementById("tbody" + k1).style.borderColor = "#ccc";

                /** проверка наличия ключ-поля */
                if (currentItem[k1]=='Код (URL)' || currentItem[k1]=='Наименование') self.keyField = true

                /** подсветка полей модификаций */
                if (currentItem[k1].indexOf("#")+1!=0) document.getElementById("mod" + k1).innerHTML = "мод."
                else                                   document.getElementById("mod" + k1).innerHTML = ""
            }

            if (self.coincidence == true)        self.errorLabel.comparison = 'ОШИБКА: совпадающие названия столбцов'
            else if (self.errorLabel.comparison) delete self.errorLabel.comparison
            if (self.keyField == false)          self.errorLabel.key = 'ОШИБКА: не выбранно ключевое поле "Ид."'
            else if (self.errorLabel.key)        delete self.errorLabel.key

            if (self.errorLabel.comparison || self.errorLabel.key)  document.getElementById("startImp").disabled = true
            else                                                    document.getElementById("startImp").disabled = false
            self.printErrorLabel()

            return true
        } // сверка значений

        self.printErrorLabel = () => {
            let errors = ''
            for (let kError in self.errorLabel)  errors += self.errorLabel[kError] + '<br/>'
            document.getElementById("errorLabel").innerHTML = errors
        } // вывод сообщений в консоль паканели импорта

        self.submit = () => {

            /**
             * отправка
             *
             * @param {bool} last - true: последний цикл
             */

            let modal = self.tags['bs-modal']
            modal.loader = true
            /** замена на пользовательские значения */
            for(var index in self.newItem.newTitele)
                self.item[0][index] = self.newItem.newTitele[index]
            for(var index in self.newItem.newDB)
                self.item[2][index] = self.newItem.newDB[index]

            items.prepare = self.item

            if(self.item.type) items.type = self.item.type
            if(self.item.reset) items.reset = self.item.reset

            items.last = false

            if(self.item.type > -1 && self.item.type < 2){

                /** прикрепляем к профилю соотношения полей */
                var profiles = JSON.parse(localStorage.getItem("profiles"))
                profiles[profiles['groupNow']]['margins'] = items.prepare[0]
                var serialProfiles = JSON.stringify(profiles)
                localStorage.setItem('profiles', serialProfiles)

                var cycleNum   = 0
                var countPages = 0
                var pages      = null
                var errors     = ''
                function repReq(pages, cycleNum) {
                    let data = {
                        'cycleNum'      : cycleNum,
                        'prepare'       : items.prepare,
                        'type'          : items.type,
                        'reset'         : items.reset,
                        'filename'      : items.filename,
                        'uploadProfile' : items.uploadProfile,
                        'last'          : items.last
                    }
                    API.request({
                        object: 'Product',
                        method: 'Import',
                        data:    data,
                        success(response) {
                            pages      = response.pages
                            cycleNum   = response.cycleNum
                            countPages = response.countPages

                            /** прогресс-бар */
                            var elem         = document.getElementById("myBar")
                            var progress     = (cycleNum+countPages)/2
                            var width        = progress / (pages) * 100
                            if (width <= 100){
                                elem.style.width = width + '%'
                                elem.innerHTML   = Math.round(width) * 1 + '%'
                                //elem.innerHTML = cycleNum+'/'+pages
                            }

                            /** терминал */
                            if (response.errors && progress >= pages) errors = response.errors + '<br/>КОНЕЦ: Импорт завершен'
                            else if (response.errors)                 errors = response.errors
                            else if (progress > pages)                errors = 'КОНЕЦ: Импорт завершен'
                            var elemT = document.getElementById("terminalImp")
                            elemT.innerHTML = errors

                            if (progress <= pages){                            /** переход в следующий цикл */
                                //cycleNum   = cycleNum + 1                    /** подгружаем следующую страницу */
                                //if(cycleNum == 0) cycleNum = cycleNum + 2
                                if (progress == pages) items.last = true;
                                return repReq(pages, cycleNum)
                            } else {                                           /** закрытие / обновление / выход из цикла */
                                 //modal.modalHide() /** закрытие второго шага импорта */
                                 observable.trigger('products-reload')
                                 observable.trigger('categories-reload')
                                 observable.trigger('special-reload')
                                 // observable.trigger('products-imports-end')
                            }
                        }
                    })
                }
                repReq(pages, cycleNum)
            }
        } // отправка