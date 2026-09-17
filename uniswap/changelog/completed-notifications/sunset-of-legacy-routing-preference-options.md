<!-- source: https://developers.uniswap.org/docs/changelog/completed-notifications/sunset-of-legacy-routing-preference-options | captured: 2026-08-22 | via: https://developers.uniswap.org/docs/changelog/completed-notifications/sunset-of-legacy-routing-preference-options.md (native markdown) -->
# Sunset of Legacy routingPreference Options (/docs/changelog/completed-notifications/sunset-of-legacy-routing-preference-options)

Posted: July 18th, 2025 | Effective: February 11th, 2026

Support for multiple legacy options for the *routingPreference* field in the /quote request has been sunset.

**What changed?**

The *routingPreference* field in the /quote request now only supports the values *BEST\_PRICE* or *FASTEST*. The legacy values of *CLASSIC*, *BEST\_PRICE\_V2*, *UNISWAPX\_V2*, *V3\_ONLY*, and *V2\_ONLY* have been removed. Submitting a request with one of these legacy values will result in an error.

**Why did this change?**

This change clarifies API request intent and allows Uniswap Labs to expand the options for routing in the future. The *routingPreference* field now only indicates the method of routing, whereas the *protocols* field indicates the protocols to be considered while executing the routing method.

**What do I need to do?**

If you are still specifying a deprecated *routingPreference* value, you **must** update your requests to use one of the supported values (*BEST\_PRICE* or *FASTEST*). You **may** also use the *protocols* field to more narrowly limit which protocols are considered for your /quote requests.

If you do not specify any value for *routingPreference*, the default is *BEST\_PRICE*.

## Legacy routingPreference to protocols Equivalency
The following table maps deprecated *routingPreference* values to equivalent *protocols* field values:

| Legacy `routingPreference` Value | Equivalent `protocols` Value |
| :------------------------------- | :--------------------------- |
| CLASSIC                          | V2, V3, V4                   |
| UNISWAPX\_V2                     | UNISWAPX\_V2                 |
| BEST\_PRICE\_V2                  | V2, V3, V4, UNISWAPX\_V2     |
| V2\_ONLY                         | V2                           |
| V3\_ONLY                         | V3                           |
