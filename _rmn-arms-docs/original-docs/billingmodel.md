
Billing Model Design for Offline Digital Signage

Billing Model Design for Offline Digital Signage

Offline store displays make it difficult to obtain direct user behavior data like web/app platforms. Instead, various billing models can be configured using device playback logs, sensor data, store traffic estimates, and time slot value.

The design below is similar to methods used by leading Retail Media Network (RMN) companies and is structured to fit operational technical foundations.

1) Billing Model Types Suitable for RMN Environment

1. Fixed CPM (Fixed Impression Unit Price, Playback-based) — Basic Model

In offline signage, the number of playbacks is treated as the number of impressions.

1 playback on display → 1 impression
Verified through device heartbeat + playback logs
Can apply weight based on video length or slot duration

Characteristics:
The most widely used offline RMN billing method in practice.

2. Dwell Time-based Fee

A method that detects the time people spend in front of the screen using camera sensors.
(Anonymized, non-identifying form of Vision AI)

Number of people + average viewing duration → Calculate weight
Cost calculation based on actual viewing duration rate relative to ad length

ex) cost = base_price * (viewer_count * dwell_multiplier)

3. Time-slot Premium Model (Time Slot Weight Model)

Instead of online CPC/CPO, offline pricing focuses on time slots when store visits peak.

Examples:
Prime time (after work 18:00-21:00): +70%
Lunch time (11:00-13:00): +30%
Early morning: -50%

ex) cost = base_cpm * time_slot_weight

4. Foot Traffic-based Model

Utilizes pedestrian flow data near devices by integrating with sensors or store POS/gate counters.

Real-time visitor count
Density during specific time slots
Traffic in specific zones

ex) cost = base_price * (traffic_index / avg_traffic)

Points with higher traffic (e.g., near checkout) have higher unit prices.

5. Playtime Guarantee Model

Same approach as "impression guarantee model" in online advertising.

Guarantee 10,000 plays per month
Automatic compensation for playback failures (additional plays to fulfill guarantee)

A method that compensates for common issues with retail store devices (offline, errors).

6. Venue-type Premium Model (Store Grade-based Price Differentiation)

Prices adjusted according to store grade (Flagship, regular, large mart, convenience store, etc.).

Examples:
Flagship Store: +200%
Large Mart: Base price
Neighborhood Supermarket: -30%

[Playback Logs] - event Driven ↓ [Valid Playback Filtering (Excluding Errors)] ↓ [Sensor/Traffic Data Integration] ↓ [Time Slot Weight Application] ↓ [Store Grade Weight] ↓ [Final Unit Price Calculation] ↓ [Budget Deduction]

