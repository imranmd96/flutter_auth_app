import mongoose, { Schema } from 'mongoose';
const userSchema = new Schema({
    _id: { type: Schema.Types.ObjectId, required: true },
    name: { type: String, required: true, trim: true },
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    phone: { type: String, trim: true },
    address: { type: String, trim: true },
    profilePicture: {
        data: Buffer,
        contentType: String
    },
    preferences: {
        notifications: { type: Boolean, default: true },
        language: { type: String, default: 'en' },
        theme: { type: String, default: 'light' },
    },
}, { timestamps: true });
export const User = mongoose.model('User', userSchema);
//# sourceMappingURL=user.model.js.map