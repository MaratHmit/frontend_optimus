| import 'pages/products/collections/groups/collections-groups.tag'
| import 'pages/products/collections/list/collections-list-wrapper.tag'
| import 'pages/products/collections/items/collections-items-wrapper.tag'

collections
    ul(if='{ !edit }').nav.nav-tabs.m-b-2
        li #[a(data-toggle='tab', href='#collections-groups') Категории]
        li #[a(data-toggle='tab', href='#collections-list') Коллекции]
        li.active #[a(data-toggle='tab', href='#collections-items') Элементы]

    .tab-content
        #collections-groups.tab-pane.fade
            collections-groups()
        #collections-list.tab-pane.fade
            collections-list-wrapper()
        #collections-items.tab-pane.fade.in.active
            collections-items-wrapper()

    script(type='text/babel').
        var self = this,
        route = riot.route.create()
            self.on('mount', () => {
            riot.route.exec()
        })