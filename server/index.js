import express from 'express';

const app = express();
const port = process.env.PORT || 3001;

app.get('/health', (_request, response) => {
  response.json({ ok: true, service: 'studio-atelier' });
});

app.listen(port, () => {
  console.log(`Studio Atelier service listening on ${port}`);
});
