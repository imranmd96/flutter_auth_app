import mongoose, { Document, Schema } from 'mongoose';
import bcrypt from 'bcryptjs';

export interface IAuthUser extends Document {
  name: string;
  email: string;
  phone: string;
  password: string;
  refreshTokens?: { token: string; createdAt: Date }[];
  role: 'user' | 'admin' | 'restaurant_owner';
  comparePassword(candidatePassword: string): Promise<boolean>;
}

const authUserSchema = new Schema<IAuthUser>(
  {
    name: { type: String, required: true, trim: true },
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    phone: { type: String, required: true, trim: true },
    password: { type: String, required: true, minlength: 6, select: false },
    refreshTokens: [
      {
        token: { type: String, required: true },
        createdAt: { type: Date, default: Date.now }
      }
    ],
    role: { type: String, enum: ['user', 'admin', 'restaurant_owner'], default: 'user' },
  },
  { timestamps: true }
);

// Hash password before saving
authUserSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

// Compare password method
authUserSchema.methods.comparePassword = async function (candidatePassword: string): Promise<boolean> {
  return bcrypt.compare(candidatePassword, this.password);
};

export const AuthUser = mongoose.model<IAuthUser>('AuthUser', authUserSchema); 