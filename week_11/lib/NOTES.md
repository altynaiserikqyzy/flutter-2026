# Practice 11 — NOTES

## GET /users and GET /users/1

- Status: `200 OK`, Content-Type: `application/json; charset=utf-8`
- `/users` → a JSON **array** of **10** users; `/users/1` → one **object**
- `/users?id=3` → an array with **one** element (a list, not an object)

### User

| field    | JSON type | Dart type | nullable? |
| -------- | --------- | --------- | --------- |
| id       | number    | int       | no        |
| name     | string    | String    | no        |
| username | string    | String    | no        |
| email    | string    | String    | no        |
| address  | object    | Address   | no        |
| phone    | string    | String    | no        |
| website  | string    | String?   | yes — the only optional field (task rule) |
| company  | object    | record `({String name, String catchPhrase, String bs})` | no |

### address (nested once; `address.geo` nested twice)

| field   | JSON type | Dart type | nullable? |
| ------- | --------- | --------- | --------- |
| street  | string    | String    | no        |
| suite   | string    | String    | no        |
| city    | string    | String    | no        |
| zipcode | string    | String    | no        |
| geo     | object    | Geo       | no        |

### address.geo

| field | JSON type               | Dart type               | nullable? |
| ----- | ----------------------- | ----------------------- | --------- |
| lat   | **string** ("-37.3159") | double (`double.parse`) | no        |
| lng   | **string** ("81.1496")  | double (`double.parse`) | no        |

### company

| field       | JSON type | Dart type | nullable? |
| ----------- | --------- | --------- | --------- |
| name        | string    | String    | no        |
| catchPhrase | string    | String    | no        |
| bs          | string    | String    | no        |

## Statuses

| request                 | status        | body |
| ----------------------- | ------------- | ---- |
| GET /users/999          | 404 Not Found | `{}` → NotFoundException |
| POST /users (JSON body) | 201 Created   | what I sent **plus** `"id": 11` |

## No-network timings

| scenario                         | time until Offline view |
| -------------------------------- | ----------------------- |
| Airplane mode                    |    2 s                  |
| Wi-Fi without internet (hotspot) |    3 s                  |