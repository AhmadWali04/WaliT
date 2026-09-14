const mongoose = require('mongoose');

const lineItemSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    description: { type: String, default: '' },
    amount: { type: Number, required: true },
  },
  { _id: false }
);

const merchantSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    address: { type: String, default: '' },
    category: { type: String, required: true },
  },
  { _id: false }
);

// timestamp is stored as the exact string the client hashed (not a Date), since
// re-serialising a Date could produce a different string and break hash verification.
const blockSchema = new mongoose.Schema({
  blockIndex: { type: Number, required: true, unique: true },
  timestamp: { type: String, required: true },
  transactionId: { type: String, required: true },
  merchant: { type: merchantSchema, required: true },
  lineItems: { type: [lineItemSchema], required: true },
  subtotal: { type: Number, required: true },
  tax: { type: Number, required: true },
  total: { type: Number, required: true },
  paymentMethod: { type: String, required: true },
  blockHash: { type: String, required: true },
  previousHash: { type: String, required: true },
  nonce: { type: Number, default: 0 },
});

module.exports = mongoose.model('Block', blockSchema);
