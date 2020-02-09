| import 'components/filemanager.tag'

files
    filemanager(value='{ value }')

    script(type='text/babel').
        var self = this,
            route = riot.route.create()

        route('files', () => {
            self.tags.filemanager.reload()
        })

        self.on('mount', () => {
            riot.route.exec()
        })