const path = require('path')

const multer = require('multer')
const sharpMulter = require('sharp-multer')

const storage = sharpMulter({
    destination: (req, file, cb) => {
        // Rename original file
        // file.originalname = file.fieldname + path.extname(file.originalname)

        // Filtering path to save
        if (file.fieldname === 'image' || file.fieldname === 'images') {
            cb(null, 'public/uploads/images')
        } else {
            cb(null, 'public/uploads')
        }
    },
    imageOptions: {
        useTimestamp: true,
        fileFormat: 'jpg',
        quality: 90,
        resize: {
            width: 1000,
            height: 1000,
            resizeMode: 'cover',
        },
    },
})

module.exports = multer({
    storage: storage,
    fileSize: 5 * 1024 * 1024,
})
