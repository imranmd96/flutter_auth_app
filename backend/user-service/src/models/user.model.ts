import mongoose, { Document, Schema } from 'mongoose';

export interface IUser extends Document {
  _id: mongoose.Types.ObjectId;
  name: string;
  email: string;
  phone?: string;
  address?: string;
  profilePicture?: {
    data: Buffer;
    contentType: string;
  };
  preferences?: {
    notifications: boolean;
    language: string;
    theme: string;
  };
  createdAt: Date;
  updatedAt: Date;
}

const userSchema = new Schema<IUser>(
  {
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
  },
  { timestamps: true }
);

export const User = mongoose.model<IUser>('User', userSchema); 