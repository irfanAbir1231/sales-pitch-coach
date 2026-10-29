# Sales Pitch Coach

Flutter app where sales officers practice pitching a product to a retailer in Bangla.
They pick a product, speak (speech-to-text, editable) or type the pitch, and get a score out of 10
with feedback. There is also an objection-handling mode where the app plays the retailer.

## Layout

- `app/` - Flutter app (Android, iOS, web)
- `data/products.json` - 121 products built from the Oct'26 call card (draft, needs review by the sales manager)
- `data/parts/`, `data/products_sample.json` - source pieces merged into `products.json`
- `app/assets/products.json` - the copy bundled into the app (keep in sync with `data/products.json`)

## Run

```
cd app
flutter pub get
flutter run -d chrome        # or a connected Android device
```

## AI providers

Scoring uses Claude, Groq or Gemini. Open **Admin** (default PIN `1234`), paste an API key,
choose the active provider and tap **Test connection**.

For local development you can instead put a Groq key in `app/lib/dev_defaults.dart`.
**Never commit that key**: it is compiled into the app.

Keys entered in Admin are stored on the device. For a wide rollout, put the keys behind a small
backend instead of shipping them in the app.
