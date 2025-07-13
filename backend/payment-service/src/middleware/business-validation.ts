import { body, param, query } from 'express-validator';
import { ValidationError } from '../utils/errors';

export const businessValidation = {
  // Restaurant business hours validation
  businessHours: {
    validate: (hours: any) => {
      const days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
      
      for (const day of days) {
        if (!hours[day]) {
          throw new ValidationError(`${day} hours are required`);
        }

        const { open, close } = hours[day];
        if (!open || !close) {
          throw new ValidationError(`${day} must have both opening and closing times`);
        }

        // Validate time format (HH:mm)
        const timeRegex = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/;
        if (!timeRegex.test(open) || !timeRegex.test(close)) {
          throw new ValidationError(`${day} times must be in HH:mm format`);
        }

        // Validate opening time is before closing time
        const openTime = new Date(`2000-01-01T${open}`);
        const closeTime = new Date(`2000-01-01T${close}`);

        if (openTime >= closeTime) {
          throw new ValidationError(`${day} opening time must be before closing time`);
        }
      }
    }
  }
}; 