const express = require('express');
const crypto = require('crypto');
const Block = require('../models/Block');

const router = express.Router();

// Mirrors cpp/WalitHashEngine.h — genesis block's previousHash.
const GENESIS_PREVIOUS_HASH = '0000000000000000';

function escapeJson(value) {
  return String(value).replace(/\\/g, '\\\\').replace(/"/g, '\\"');
}

function formatAmount(amount) {
  return Number(amount).toFixed(2);
}

function serializeLineItems(lineItems) {
  return (
    '[' +
    lineItems
      .map(
        (item) =>
          `{"name":"${escapeJson(item.name)}","description":"${escapeJson(item.description)}","amount":${formatAmount(item.amount)}}`
      )
      .join(',') +
    ']'
  );
}

// Matches the chaining rule in Section 5 of the PRD and cpp/WalitHashEngine.cpp's
// computeBlockHash, byte-for-byte, so client-, server- and C++-computed hashes agree.
function computeBlockHash({ blockIndex, timestamp, lineItems, total, previousHash, nonce }) {
  const canonical =
    String(blockIndex) +
    timestamp +
    serializeLineItems(lineItems) +
    formatAmount(total) +
    previousHash +
    String(nonce);
  return crypto.createHash('sha256').update(canonical).digest('hex');
}

// GET /receipts/verify - must be registered before /:id so "verify" isn't parsed as an id.
router.get('/verify', async (req, res) => {
  const blocks = await Block.find().sort({ blockIndex: 1 });

  for (let i = 0; i < blocks.length; i++) {
    const block = blocks[i];
    const expectedPreviousHash = i === 0 ? GENESIS_PREVIOUS_HASH : blocks[i - 1].blockHash;

    if (block.previousHash !== expectedPreviousHash) {
      return res.json({ valid: false, firstInvalidIndex: block.blockIndex });
    }

    const recomputedHash = computeBlockHash({
      blockIndex: block.blockIndex,
      timestamp: block.timestamp,
      lineItems: block.lineItems,
      total: block.total,
      previousHash: block.previousHash,
      nonce: block.nonce,
    });

    if (recomputedHash !== block.blockHash) {
      return res.json({ valid: false, firstInvalidIndex: block.blockIndex });
    }
  }

  res.json({ valid: true });
});

// GET /receipts - all blocks, sorted by blockIndex
router.get('/', async (req, res) => {
  const blocks = await Block.find().sort({ blockIndex: 1 });
  res.json(blocks);
});

// GET /receipts/:id - single block by MongoDB _id
router.get('/:id', async (req, res) => {
  const block = await Block.findById(req.params.id).catch(() => null);
  if (!block) return res.status(404).json({ error: 'Block not found' });
  res.json(block);
});

// POST /receipts - validates previousHash/blockIndex linkage and blockHash, then stores
router.post('/', async (req, res) => {
  const {
    blockIndex, timestamp, transactionId, merchant, lineItems,
    subtotal, tax, total, paymentMethod, blockHash, previousHash, nonce,
  } = req.body;

  if (
    blockIndex === undefined || !timestamp || !transactionId || !merchant ||
    !Array.isArray(lineItems) || subtotal === undefined || tax === undefined ||
    total === undefined || !paymentMethod || !blockHash || previousHash === undefined
  ) {
    return res.status(400).json({ error: 'Missing required receipt fields' });
  }

  const lastBlock = await Block.findOne().sort({ blockIndex: -1 });
  const expectedBlockIndex = lastBlock ? lastBlock.blockIndex + 1 : 0;
  const expectedPreviousHash = lastBlock ? lastBlock.blockHash : GENESIS_PREVIOUS_HASH;

  if (blockIndex !== expectedBlockIndex || previousHash !== expectedPreviousHash) {
    return res.status(409).json({
      error: 'Chain linkage mismatch',
      expectedBlockIndex,
      expectedPreviousHash,
    });
  }

  const recomputedHash = computeBlockHash({
    blockIndex, timestamp, lineItems, total, previousHash, nonce: nonce ?? 0,
  });
  if (recomputedHash !== blockHash) {
    return res.status(400).json({ error: 'blockHash does not match recomputed hash' });
  }

  const block = await Block.create({
    blockIndex, timestamp, transactionId, merchant, lineItems,
    subtotal, tax, total, paymentMethod, blockHash, previousHash, nonce: nonce ?? 0,
  });

  res.status(201).json(block);
});

module.exports = router;
