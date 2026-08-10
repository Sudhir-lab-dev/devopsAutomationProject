import { Router } from 'express';
import multer from 'multer';
import { uploadCsv } from '../controllers/csv.controller';

const router = Router();

const upload = multer({
    dest: 'uploads/',
    limits: {
        fileSize: 5 * 1024 * 1024,
    },
    fileFilter: (_req, file, cb) => {

        if (
            file.mimetype === 'text/csv' ||
            file.originalname.toLowerCase().endsWith('.csv')
        ) {
            cb(null, true);
        } else {
            cb(new Error('Only CSV files are allowed'));
        }
    },
});

router.post(
    '/upload',
    upload.single('file'),
    uploadCsv
);

export default router;