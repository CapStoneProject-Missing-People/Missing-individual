import { body } from 'express-validator';

export const validateMessage = [
  body('receiver')
    .notEmpty().withMessage('Receiver is required')
    .isMongoId().withMessage('Invalid receiver ID format'),
  
  body('message')
    .if(body('imageBase64').not().exists())
    .notEmpty().withMessage('Message is required when no image is provided')
    .isString().withMessage('Message must be a string')
    .isLength({ max: 2000 }).withMessage('Message cannot exceed 2000 characters'),
  
  body('imageBase64')
    .optional()
    .isString().withMessage('Image must be Base64 encoded')
    .custom((value) => {
      if (value && !value.startsWith('data:image/')) {
        throw new Error('Invalid Base64 image format');
      }
      return true;
    })
];
