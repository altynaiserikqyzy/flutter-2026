typedef Company = ({String name, String catchPhrase, String bs});

class Geo {
  const Geo({required this.lat, required this.lng});

  /// The server sends lat / lng as STRINGS ("-37.3159").
  factory Geo.fromJson(Map<String, dynamic> json) => Geo(
    lat: double.parse(json['lat'] as String),
    lng: double.parse(json['lng'] as String),
  );

  final double lat;
  final double lng;

  Map<String, dynamic> toJson() => {
    'lat': lat.toString(),
    'lng': lng.toString(),
  };
}

class Address {
  const Address({
    required this.street,
    required this.suite,
    required this.city,
    required this.zipcode,
    required this.geo,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    street: json['street'] as String,
    suite: json['suite'] as String,
    city: json['city'] as String,
    zipcode: json['zipcode'] as String,
    geo: Geo.fromJson(json['geo'] as Map<String, dynamic>),
  );

  final String street;
  final String suite;
  final String city;
  final String zipcode;
  final Geo geo;

  Map<String, dynamic> toJson() => {
    'street': street,
    'suite': suite,
    'city': city,
    'zipcode': zipcode,
    'geo': geo.toJson(),
  };
}

class User {
  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.address,
    required this.company,
    this.website,
  });

  /// Every cast is a claim: if the server breaks it, we throw at the field.
  factory User.fromJson(Map<String, dynamic> json) {
    final c = json['company'] as Map<String, dynamic>;
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      website: json['website'] as String?, // the only optional field
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      company: (
        name: c['name'] as String,
        catchPhrase: c['catchPhrase'] as String,
        bs: c['bs'] as String,
      ),
    );
  }

  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String? website;
  final Address address;
  final Company company;

  /// Raw phone kept as is; this getter keeps only digits and '+'.
  String get phoneDigits => phone.replaceAll(RegExp(r'[^\d+]'), '');

  /// Same shape the server sent, nested maps included.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'email': email,
    'address': address.toJson(),
    'phone': phone,
    if (website != null) 'website': website,
    'company': {
      'name': company.name,
      'catchPhrase': company.catchPhrase,
      'bs': company.bs,
    },
  };

  @override
  bool operator ==(Object other) => other is User && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User($id, $name, @$username, $email)';
}
