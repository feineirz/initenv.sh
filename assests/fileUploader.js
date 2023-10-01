const path = require('path')

const multer = require('multer')

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        // Rename original file
        // file.originalname = file.fieldname + path.extname(file.originalname)

        // Filtering path to save
        if (file.fieldname === 'file' || file.fieldname === 'files') {
            cb(null, 'public/uploads/files')
        } else {
            cb(null, 'public/uploads')
        }
    },
    filename: (req, file, cb) => {
        cb(null, `file-${Date.now()}${path.extname(file.originalname)}`)
    },
})

module.exports = multer({
    storage: storage,
    fileSize: 25 * 1024 * 1024,
})
