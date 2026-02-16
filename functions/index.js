const functions = require('firebase-functions/v1');
const admin = require('firebase-admin');
const { algoliasearch } = require('algoliasearch');

admin.initializeApp();

// ---------------------------------------------------------
// ✨ CONFIGURATION
// ---------------------------------------------------------
// Configured for User Demo
const ALGOLIA_APP_ID = "MD07DD1WL2";
const ALGOLIA_ADMIN_KEY = "b935bc494abe58bac38dee840c9fc5a9"; // Write API Key
const ALGOLIA_INDEX_NAME = 'products';

// Initialize Algolia (v5)
const client = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);

// ---------------------------------------------------------
// 🚀 CLOUD FUNCTIONS
// ---------------------------------------------------------

/**
 * Trigger: When a new Product is created/updated in Firebase
 * Path: DigiLocal/{shopId}/Products/{productId}
 */
exports.onProductWrite = functions.database
  .ref('/DigiLocal/{shopId}/Products/{productId}')
  .onWrite(async (change, context) => {
    const { shopId, productId } = context.params;

    // 1. DELETE Case
    if (!change.after.exists()) {
      console.log(`🗑️ Deleting product ${productId} from Algolia`);
      await client.deleteObject({
        indexName: ALGOLIA_INDEX_NAME,
        objectID: productId,
      });
      return null;
    }

    const productData = change.after.val();

    // Fetch Shop Info to add context
    const shopSnapshot = await admin.database().ref(`/DigiLocal/${shopId}`).once('value');
    const shopData = shopSnapshot.val() || {};
    const shopInfo = shopData.shopInfo || {};

    // 2. CREATE / UPDATE Case
    const record = {
      objectID: productId,
      // Product Fields
      title: productData.title,
      description: productData.description,
      category: productData.category,
      price: parseFloat(productData.productprice || 0),
      image: productData.image,

      // Shop Context
      shopId: shopId,
      shopName: shopInfo.shopName || shopData.name,
      shopArea: shopInfo.address,

      // Geo-Search
      _geoloc: {
        lat: shopData.latitude,
        lng: shopData.longitude
      },

      // Availability
      isInStock: (parseInt(productData.itemLeft || 0) > 0),
      rating: parseFloat(productData.rating || 0),
    };

    console.log(`✨ Syncing product ${productId} to Algolia`, record.title);

    // Save to Algolia (v5)
    await client.saveObject({
      indexName: ALGOLIA_INDEX_NAME,
      body: record,
    });

    return null;
  });
