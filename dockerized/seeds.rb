# This seed file is mounted inside eis-registry service container during drone tests, and it ensures eis registry has all the data we need
#  for our unit tests

utc_now = Time.zone.now.utc

# Add admin user
AdminUser.where(
    username: 'user1',
).first_or_create!(
  username: 'user1',
  email: 'user1@example.ee',
  identity_code: '37810013855',
  country_code: 'EE',
  password: 'testtest',
  password_confirmation: 'testtest',
  roles: ['admin']
)

# configure EE zone
ZonefileSetting.where({
  origin: 'ee',
  ttl: 43200,
  refresh: 3600,
  retry: 900,
  expire: 1209600,
  minimum_ttl: 3600,
  email: 'hostmaster.eestiinternet.ee',
  master_nameserver: 'ns.tld.ee'
}).first_or_create!

# Disable ip whitelists
Setting.registrar_ip_whitelist_enabled = false
Setting.api_ip_whitelist_enabled = false

# Create registrar 1
registrar1 = Registrar.where(
  name: 'Registrar First AS',
  reg_no: '10300220',
  street: 'Pärnu mnt 2',
  city: 'Tallinn',
  state: 'Harju maakond',
  zip: '11415',
  email: 'registrar1@example.com',
  country_code: 'EE',
  code: 'REG1'
).first_or_create!

# Create dummy contact for registrar1
Contact.where(
  code: 'REG1:DUMMY-CONTACT',
  registrar: registrar1,
).first_or_create!(
  name: 'Smith Johnson',
  phone: '+372.53944251',
  email: 'smithie@johnson.sdf',
  street: 'Pine 1',
  city: 'Forest',
  zip: '12345',
  country_code: 'ee',
  ident: '47101010033',
  ident_type: 'priv',
  ident_country_code: 'ee'
)

# Create api user for registrar1
@api_user1 = ApiUser.where(
  username: 'registrar1',
).first_or_create!(
  password: 'password',
  identity_code: '51001091072',
  active: true,
  registrar: registrar1,
  roles: ['super']
)

# From registrar1.csr.pem
csr = "-----BEGIN CERTIFICATE REQUEST-----\n" \
      "MIIEpjCCAo4CAQAwYTELMAkGA1UEBhMCRUUxEzARBgNVBAgMClNvbWUtU3RhdGUx\n" \
      "EzARBgNVBAoMCnJlZ2lzdHJhcjExEzARBgNVBAsMCnJlZ2lzdHJhcjExEzARBgNV\n" \
      "BAMMCnJlZ2lzdHJhcjEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC2\n" \
      "JQrZYQa5ER672XBU0V+TPt5P+PEmvgOq/AUuvnVRnrFedR3Timjvs5Fum86qBkao\n" \
      "F10MUKmTFAaZEkx88quWrp+ezCi7rElqlhWoymX7wtkKAsrAroqOvHNRuHMSg0Qx\n" \
      "PRaG2oGXwJMB0vIdtjz35DAysRQVadJCLGN2QsRvXmRmbvcTB8SiuMwQZdLneMXY\n" \
      "ETU9hb7ivzSWfiKiFhaEhajbwXVQZ8Go40feMdXe+W1QhkHxB0zRR5XHV7HFoorY\n" \
      "CSZZOBOGlWO2o9NVf3lbQPlcOMoVr75nSu5imcir+lWmq0DJeO2i51haznLlbztx\n" \
      "52qlR4GUobSHTTbOYJkPuq4Qs/aPmjUMCpRcFaaev9aDkZJ2spQKrVfohdMLKKj+\n" \
      "C37NAIA1V7W5yqgz04zrT5PqmaXRNxOAd4H1fDkdSCETKOqlWSysuWBsITJhc8eC\n" \
      "N2OlPvcWcb8R7DGBTR+BQvmx906EW+FnOungF71TWoWTrZuf8RkHwcM8gK2nitFC\n" \
      "RjywOZ4C6bpJ0N7lAB/Ayf+oG2PzAmYXlXFICUtGkUdtXxc5jVo0ZqD+hce4nesQ\n" \
      "qDwyd/tn3yIyUEjQ29fOh6fR2bIyBu7kIQrNkzzrZv4l7vKwuC4YTslMi3KuyztH\n" \
      "SRXD1d1BiudplymJ5HCnkeKHwQXbv4KlriqJvGzHqQIDAQABoAAwDQYJKoZIhvcN\n" \
      "AQELBQADggIBACX7vQlmNLvlVYr5v396sqKLQmz4aFLuRb4rSGMNbpaR2rD+ggpM\n" \
      "RLu54qpYfNf6hj7V4pU60nz80WPKfiywGk7M0WMa8SDHhk90+gNQum2MnlYpUKKz\n" \
      "VbAfMhwjdKGgU+Mf5nHMrEt1XmA+oFNrzL1NCFT9GGESAn6MJPrhVVd1f1vRyJKg\n" \
      "3S1ITNpVjmZ3rbhKfs5bMoBFT+fiHinjvmGzEZAiJ37eKqhOvwFOQRefx5IZBFXv\n" \
      "lr5WmgC+3CSxc8eXPu1QFjHzEmqkOfVKjFzkvZwxXKeIbf9izRW9K6WHX6ObodYY\n" \
      "UbcdbdIuIyxEcMpWFxXr0pTmZ1VfaDTyw+iGZ2U12OMyHNg0a2tfePpPQhrhXPfQ\n" \
      "/FY7wvowln9BU4ONwPhAG4XgrX5SjEFuA7859bPcrP+BuUp7YQne5+U50Dp+A2m6\n" \
      "nCB6RtZgCy17UrtjiiXxN3sHGQ/iCwwc1JjlZ2pWdXhDKINiZHavKN6Vb5AlZpwu\n" \
      "LZG5pyqKBsDJ/teEl3RruKzeIixXz6xNJcmrKKW5E4hQssdOsJxzJgbA65p/b3bC\n" \
      "HDUnIIc9QpdFFL/Q0hdD5eGkDiBZAMVxCNJ/ALUbUhC7xk9l32tqCBOuwAAMNLlv\n" \
      "nRyt0w+vy/QvDs3scSMWb1DEy8qQGk/TeijsNV/XuMWcuNUD2AO1wV4v\n" \
      "-----END CERTIFICATE REQUEST-----\n\n"

# From registrar1.crt.pem
crt = "-----BEGIN CERTIFICATE-----\n" \
      "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\n" \
      "-----END CERTIFICATE-----\n"

@certifcate1 = Certificate.where(
    api_user: @api_user1,
    interface: "registrar",
).first_or_create!(
    common_name: "registrar1",
    csr: csr,
    crt: nil,
)

@certifcate1.crt = crt
@certifcate1.md5 = "7197df8de45d25bf6b6b210e2ff12792"
@certifcate1.save!(validate: false)

Certificate.where(
    api_user: @api_user1,
    interface: "api",
).first_or_create!(
    common_name: "registrar1",
    md5: "7197df8de45d25bf6b6b210e2ff12792",
    csr: nil,
    crt: crt,
)

# Add `drm-modify-contacts.ee` domain for registrar1
modify_contacts_domain = Domain.new(
  name: 'drm-modify-contacts.ee',
  period: 1,
  period_unit: 'y',
  auth_info: 'ritopls',
  registrar: registrar1,
  registrant: Registrant.where(
      code: 'REG1:TEST-REG-1000',
      registrar: registrar1,
    ).first_or_create!(
      name: 'Jamie Doliver',
      phone: '+372.54914251',
      email: 'jame@doliver.sdf',
      street: 'Elk 1',
      city: 'Forestry',
      zip: '11413',
      country_code: 'ee',
      ident: '47101010033',
      ident_type: 'priv',
      ident_country_code: 'ee'
    ),
  created_at: utc_now.beginning_of_day,
  registered_at: utc_now.beginning_of_day,
  valid_from: utc_now.beginning_of_day,
  valid_to: utc_now.beginning_of_day + 1.year + 1.day,
)
modify_contacts_domain.nameservers.build(hostname: 'ns1.fake.sdf', ipv4: Array['192.168.12.1'], ipv6: nil)
modify_contacts_domain.nameservers.build(hostname: 'ns2.fake.sdf', ipv4: Array['192.168.12.2'], ipv6: nil)
modify_contacts_domain.admin_contacts << Contact.where(
  code: 'REG1:TEST-ADMIN-1001',
  registrar: registrar1,
).first_or_create!(
  name: 'Admin Istraator',
  phone: '+372.532122271',
  email: 'admin.istraator@example.com',
  street: 'Haapsalu mnt 11b',
  city: 'Tallinn',
  zip: '18712',
  country_code: 'ee',
  ident: '47101010033',
  ident_type: 'priv',
  ident_country_code: 'ee'
)
modify_contacts_domain.tech_contacts << Contact.where(
  code: 'REG1:TEST-TECH-1002',
  registrar: registrar1,
).first_or_create!(
  name: 'Tehni Kamees',
  phone: '+372.512924251',
  email: 'tehni@kamees.eu',
  street: 'Vilde tee 104',
  city: 'Tallinn',
  zip: '12674',
  country_code: 'ee',
  ident: '47101010033',
  ident_type: 'priv',
  ident_country_code: 'ee'
)
modify_contacts_domain.save()

# Add `drm-owner-change.ee` domain for registrar1
owner_change_domain = Domain.new(
  name: 'drm-owner-change.ee',
  period: 1,
  period_unit: 'y',
  auth_info: 'loki',
  registrar: registrar1,
  registrant: Registrant.where(
      code: 'REG1:TEST-REG-1003',
      registrar: registrar1,
    ).first_or_create!(
      name: 'Luke Skytalker',
      phone: '+372.53728134',
      email: 'luke@skytalker.sdf',
      street: 'Log 1',
      city: 'Forestry',
      zip: '10622',
      country_code: 'ee',
      ident: '47101010033',
      ident_type: 'priv',
      ident_country_code: 'ee'
    ),
  created_at: utc_now.beginning_of_day,
  registered_at: utc_now.beginning_of_day,
  valid_from: utc_now.beginning_of_day,
  valid_to: utc_now.beginning_of_day + 1.year + 1.day,
)
owner_change_domain.nameservers.build(hostname: 'ns1.fake.sdf', ipv4: Array['192.168.12.1'], ipv6: nil)
owner_change_domain.nameservers.build(hostname: 'ns2.fake.sdf', ipv4: Array['192.168.12.2'], ipv6: nil)
owner_change_domain.admin_contacts << Contact.where(
  code: 'REG1:TEST-ADMIN-1004',
  registrar: registrar1,
).first_or_create!(
  name: 'Leia Skytalker',
  phone: '+372.532122271',
  email: 'leia.skytalker@example.com',
  street: 'Pärnu mnt 7b',
  city: 'Tallinn',
  zip: '14702',
  country_code: 'ee',
  ident: '47101010033',
  ident_type: 'priv',
  ident_country_code: 'ee'
)
owner_change_domain.tech_contacts << Contact.where(
  code: 'REG1:TEST-TECH-1005',
  registrar: registrar1,
).first_or_create!(
  name: 'Obi wan Kenodi',
  phone: '+372.512924251',
  email: 'obiwan@kenodi.eu',
  street: 'Telgi tee 104',
  city: 'Tallinn',
  zip: '11654',
  country_code: 'ee',
  ident: '47101010033',
  ident_type: 'priv',
  ident_country_code: 'ee'
)
owner_change_domain.save()

# Add `drm-modify-nameservers.ee` domain for registrar1
modify_ns_domain = Domain.new(
  name: 'drm-modify-nameservers.ee',
  period: 1,
  period_unit: 'y',
  auth_info: 'hug-star',
  registrar: registrar1,
  registrant: Registrant.where(
      code: 'REG1:TEST-REG-1003',
      registrar: registrar1,
    ).first_or_create!(
      name: 'Jabba de Nutt',
      phone: '+372.53728134',
      email: 'jabba@de-nutt.sdf',
      street: 'Log 1',
      city: 'Forestry',
      zip: '10622',
      country_code: 'ee',
      ident: '47101010033',
      ident_type: 'priv',
      ident_country_code: 'ee'
    ),
  created_at: utc_now.beginning_of_day,
  registered_at: utc_now.beginning_of_day,
  valid_from: utc_now.beginning_of_day,
  valid_to: utc_now.beginning_of_day + 1.year + 1.day,
)
modify_ns_domain.nameservers.build(hostname: 'ns1.fake.sdf', ipv4: Array['192.168.12.1'], ipv6: nil)
modify_ns_domain.nameservers.build(hostname: 'ns2.fake.sdf', ipv4: Array['192.168.12.2'], ipv6: nil)
modify_ns_domain.admin_contacts << Contact.where(
  code: 'REG1:TEST-ADMIN-1004',
  registrar: registrar1,
).first_or_create!(
  name: 'Bobba Jett',
  phone: '+372.532122271',
  email: 'bobba.jett@example.com',
  street: 'Pärnu mnt 7b',
  city: 'Tallinn',
  zip: '14702',
  country_code: 'ee',
  ident: '47101010033',
  ident_type: 'priv',
  ident_country_code: 'ee'
)
modify_ns_domain.tech_contacts << Contact.where(
  code: 'REG1:TEST-TECH-1005',
  registrar: registrar1,
).first_or_create!(
  name: 'Jar Jar Jinx',
  phone: '+372.512924251',
  email: 'jar@jar-jinx.eu',
  street: 'Telgi tee 104',
  city: 'Tallinn',
  zip: '11654',
  country_code: 'ee',
  ident: '47101010033',
  ident_type: 'priv',
  ident_country_code: 'ee'
)
modify_ns_domain.save()

# Add `drm-renew.ee` domain for registrar1
renew_domain = Domain.new(
  name: 'drm-renew.ee',
  period: 1,
  period_unit: 'y',
  auth_info: 'Datoiine',
  registrar: registrar1,
  registrant: Registrant.where(
      code: 'REG1:TEST-REG-1005',
      registrar: registrar1,
    ).first_or_create!(
      name: 'Adi Gallia',
      phone: '+372.54914251',
      email: 'adi@gallia.sdf',
      street: 'Elk 1',
      city: 'Coruscant',
      zip: '11413',
      country_code: 'ee',
      ident: '47101010033',
      ident_type: 'priv',
      ident_country_code: 'ee'
    ),
  created_at: utc_now.beginning_of_day - 1.year,
)
renew_domain.nameservers.build(hostname: 'ns1.fake.sdf', ipv4: Array['192.168.12.1'], ipv6: nil)
renew_domain.nameservers.build(hostname: 'ns2.fake.sdf', ipv4: Array['192.168.12.2'], ipv6: nil)
renew_domain.admin_contacts << Contact.where(
  code: 'REG1:TEST-ADMIN-1005',
  registrar: registrar1,
).first_or_create!(
  name: 'Gre Edo',
  phone: '+372.532122271',
  email: 'gre@edo.sdf',
  street: 'Haapsalu mnt 11b',
  city: 'Tallinn',
  zip: '18712',
  country_code: 'ee',
  ident: '47101010033',
  ident_type: 'priv',
  ident_country_code: 'ee'
)
renew_domain.tech_contacts << Contact.where(
  code: 'REG1:TEST-TECH-1005',
  registrar: registrar1,
).first_or_create!(
  name: 'Wedge Antilles',
  phone: '+372.512924251',
  email: 'wedge@antilles.sdf',
  street: 'Moon 199',
  city: 'Corellia',
  zip: '12674',
  country_code: 'ee',
  ident: '47101010033',
  ident_type: 'priv',
  ident_country_code: 'ee'
)
renew_domain.save()
renew_domain.registered_at = utc_now.beginning_of_day - 1.year
renew_domain.valid_from = utc_now.beginning_of_day - 1.year
renew_domain.valid_to = utc_now.beginning_of_day + 1.day
renew_domain.save()

# Create registrar 2
registrar2 = Registrar.where(
  name: 'Registrar Second AS',
  reg_no: '1234567',
  street: 'Oak 1',
  city: 'Forest',
  state: 'County',
  zip: '12345',
  email: 'registrar2@example.com',
  country_code: 'EE',
  code: 'REG2'
).first_or_create!

# Create registrar2 contact
registrar2_contact = Contact.where(
  code: 'REG2:ROOT',
  registrar: registrar2,
).first_or_create!(
  name: 'Registrar Second AS',
  phone: '+372.54924251',
  email: 'registrar2@example.com',
  street: 'Oak 1',
  city: 'Forest',
  zip: '12345',
  country_code: 'ee',
  ident: '12560006',
  ident_type: 'org',
  ident_country_code: 'ee'
)

# Create registrar2 REG contact
registrar2_reg_contact = Registrant.where(
  code: 'REG2:REGISTRANT-CONTACT',
  registrar: registrar2,
).first_or_create!(
  name: 'Janet Doe',
  phone: '+372.54924251',
  email: 'janet@doeson.sdf',
  street: 'Oak 1',
  city: 'Forest',
  zip: '12453',
  country_code: 'ee',
  ident: '47101010033',
  ident_type: 'priv',
  ident_country_code: 'ee'
)

# Add `epp-transferdomain.ee` domain for registrar2
transfer_domain1 = Domain.new(
  name: 'epp-transferdomain.ee',
  period: 1,
  period_unit: 'y',
  auth_info: 'super_secure_pw',
  registrar: registrar2,
  registrant: registrar2_reg_contact,
  created_at: utc_now.beginning_of_day,
  registered_at: utc_now.beginning_of_day,
  valid_from: utc_now.beginning_of_day,
  valid_to: utc_now.beginning_of_day + 1.year + 1.day,
)
transfer_domain1.nameservers.build(hostname: 'ns1.fake.sdf', ipv4: Array['192.168.12.1'], ipv6: nil)
transfer_domain1.nameservers.build(hostname: 'ns2.fake.sdf', ipv4: Array['192.168.12.2'], ipv6: nil)
transfer_domain1.admin_contacts << registrar2_contact
transfer_domain1.tech_contacts << registrar2_contact
transfer_domain1.save()

# Add `drm-transferdomain.ee` domain for registrar2
transfer_domain2 = Domain.new(
  name: 'drm-transferdomain.ee',
  period: 1,
  period_unit: 'y',
  auth_info: 'dontstealmydomain',
  registrar: registrar2,
  registrant: registrar2_reg_contact,
  created_at: utc_now.beginning_of_day,
  registered_at: utc_now.beginning_of_day,
  valid_from: utc_now.beginning_of_day,
  valid_to: utc_now.beginning_of_day + 1.year + 1.day,
)
transfer_domain2.nameservers.build(hostname: 'ns1.fake.sdf', ipv4: Array['192.168.12.1'], ipv6: nil)
transfer_domain2.nameservers.build(hostname: 'ns2.fake.sdf', ipv4: Array['192.168.12.2'], ipv6: nil)
transfer_domain2.admin_contacts << registrar2_contact
transfer_domain2.tech_contacts << registrar2_contact
transfer_domain2.save()

# Add `transfer-info.ee` domain for registrar2
transfer_domain3 = Domain.new(
  name: 'transfer-info.ee',
  period: 1,
  period_unit: 'y',
  auth_info: 'wingz',
  registrar: registrar2,
  registrant: registrar2_reg_contact,
  created_at: utc_now.beginning_of_day,
  registered_at: utc_now.beginning_of_day,
  valid_from: utc_now.beginning_of_day,
  valid_to: utc_now.beginning_of_day + 1.year + 1.day,
)
transfer_domain3.nameservers.build(hostname: 'ns1.fake.sdf', ipv4: Array['192.168.12.1'], ipv6: nil)
transfer_domain3.nameservers.build(hostname: 'ns2.fake.sdf', ipv4: Array['192.168.12.2'], ipv6: nil)
transfer_domain3.admin_contacts << registrar2_contact
transfer_domain3.tech_contacts << registrar2_contact
transfer_domain3.save()

# Add api user for registrar2
@api_user2 = ApiUser.where(
  username: 'registrar2',
).first_or_create!(
  password: 'password',
  identity_code: '12560006',
  active: true,
  registrar: registrar2,
  roles: ['super']
)

# From registrar2.csr.pem
csr2 = "-----BEGIN CERTIFICATE REQUEST-----\n" \
       "MIICxzCCAa8CAQAwgYExCzAJBgNVBAYTAkVFMRMwEQYDVQQIDApTb21lLVN0YXRl\n" \
       "MSEwHwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQxEzARBgNVBAMMCnJl\n" \
       "Z2lzdHJhcjIxJTAjBgkqhkiG9w0BCQEWFnJlZ2lzdHJhcjJAZXhhbXBsZS5jb20w\n" \
       "ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCdMRMXPrZdXVeTmHwlRUTB\n" \
       "+d1Gx8nOkAnXSwMtPqlsJBvU1JAQm/Xh2FBcvt/Wx6L8BnC6gWZe5LMNpVN/HGOv\n" \
       "bBX/GerpmQZ70WB0mheB2SbXIwmG2n0vnJokxYk4iFk0SfLwdjhpO6YyiJ/kCFxd\n" \
       "SaUnpsOvFMo7j92nG/pvinRW8h63vhqpR2H7TddISMrze8ru/8qGE2mPVFCTjmM+\n" \
       "zQkzf+gA1llEwiObyK09zI5wsuXqKV2/NDjICpjm2uGCKe+xDRzetJ44A9prWNil\n" \
       "AYzIqkXWW1b1PcvzUVqp/3V2pFJgZVkc/K+SzwALClHMw/LXJYQUsgPe+MulWxWP\n" \
       "AgMBAAGgADANBgkqhkiG9w0BAQsFAAOCAQEAMCTUx7JSanG220cXyEaSfdYF0eLY\n" \
       "TAH0WFU++/iLmc/OZNzC5MnciGAntnp5HQ5sU54rqnBi4A7DokNyGmYbhN+Q4St4\n" \
       "RXcOg4IgTvADoncmoLMFIHqr7rWTJ7odsTGR0kEstdJ1NfU0WnNg7B3aS4v4CMwZ\n" \
       "nEqEBr7oEMYLnALyM+R0N7WYXlHoRpWLF6PhGL1QxDBQU5Aicij4u1Vor/R3pwdz\n" \
       "OVGLkeo9IscyA47MfE5owIOSJgD09nHJVRXHwFcCvd/GVqhFPXe9mfkmFiIrYxcX\n" \
       "Sc6mNsHR5de9s4zRbJkpmuZxOClqlz5rKXYoAWFH7sakLuFTwXpS8uI3mg==\n" \
       "-----END CERTIFICATE REQUEST-----\n"

# From registrar2.crt.pem
crt2 = "-----BEGIN CERTIFICATE-----\n" \
       "MIIErDCCApSgAwIBAgICEAEwDQYJKoZIhvcNAQELBQAwJDELMAkGA1UEBhMCRUUx\n" \
       "FTATBgNVBAMMDGNhLmVpcy5sb2NhbDAeFw0xNjExMTAxMzI2MDNaFw0xNzExMTAx\n" \
       "MzI2MDNaMIGBMQswCQYDVQQGEwJFRTETMBEGA1UECAwKU29tZS1TdGF0ZTEhMB8G\n" \
       "A1UECgwYSW50ZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMRMwEQYDVQQDDApyZWdpc3Ry\n" \
       "YXIyMSUwIwYJKoZIhvcNAQkBFhZyZWdpc3RyYXIyQGV4YW1wbGUuY29tMIIBIjAN\n" \
       "BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnTETFz62XV1Xk5h8JUVEwfndRsfJ\n" \
       "zpAJ10sDLT6pbCQb1NSQEJv14dhQXL7f1sei/AZwuoFmXuSzDaVTfxxjr2wV/xnq\n" \
       "6ZkGe9FgdJoXgdkm1yMJhtp9L5yaJMWJOIhZNEny8HY4aTumMoif5AhcXUmlJ6bD\n" \
       "rxTKO4/dpxv6b4p0VvIet74aqUdh+03XSEjK83vK7v/KhhNpj1RQk45jPs0JM3/o\n" \
       "ANZZRMIjm8itPcyOcLLl6ildvzQ4yAqY5trhginvsQ0c3rSeOAPaa1jYpQGMyKpF\n" \
       "1ltW9T3L81Faqf91dqRSYGVZHPyvks8ACwpRzMPy1yWEFLID3vjLpVsVjwIDAQAB\n" \
       "o4GJMIGGMAkGA1UdEwQCMAAwCwYDVR0PBAQDAgXgMCwGCWCGSAGG+EIBDQQfFh1P\n" \
       "cGVuU1NMIEdlbmVyYXRlZCBDZXJ0aWZpY2F0ZTAdBgNVHQ4EFgQUk53IyrY+/SBu\n" \
       "UisdtZlxPQr/88owHwYDVR0jBBgwFoAUxxMEsEwQ/5jSv2WkoTtTmyjWaJcwDQYJ\n" \
       "KoZIhvcNAQELBQADggIBAIoNG98aAUuwmVBRznLxY2UwcEQ8OQG047XphoPTEVvQ\n" \
       "xLPO6Krx7ZAaCAU1CX5WOOe0JjIADCbru0iIUZ1mYnEqQLcKpYM0exG2OCT/XbBo\n" \
       "LC9XZATaQ5hAhljFCkHF95vFNb5Fv1w9CgRsh0f+LDztN9iwCyxm10J9JvbWBhpH\n" \
       "wjNv45Q2RdfajQj6XacXBxKlu5xBLjOnxyp+XGoeKArO6SVyLEmoJGJVBb7r8Av1\n" \
       "g9o7m0xJQTsSttNIcCBhJCD5BqM7YZBUVpih849mm0LKRLKliaalBnZDw82K8eP/\n" \
       "sGvtq3s37/GRR+44Og1IZ8GA/X/VQNoy4ZRLiz64RRyKfH5kYd5bWy5SMrtRXPa6\n" \
       "pCq/nvWlfDlHxAHxU0o/V99JW+jJLtLaS0GhBJYLyLpcsFPUeXCx9nacpihAv/us\n" \
       "mBiMiyQwya9LuwLrfYUSn7t91YaJ/OVlMnTA2qkKxlwDZ10BiiOHqFDuE6vBltQX\n" \
       "G/5QUfQkmWu0/PuavbGawvuRHlEFDm65mgQW1v5+cFtaV4tYn2GLJZ65m2pChgTD\n" \
       "5SwIfgvg3OHVhhe6gv3qrQGx+JQxs4piIWV+/OnA2DZDLyuWJQhRJnIyNTVskqP+\n" \
       "JIa1paNH0AS6GUvzYMUYtb6KfglS8PWvB7WMyiIxTiZIdQH0b4u6H8lrr7T/dS1N\n" \
       "-----END CERTIFICATE-----\n"

@certifcate2 = Certificate.where(
    api_user: @api_user2,
    interface: "registrar",
).first_or_create!(
    common_name: "registrar2",
    csr: csr2,
    crt: nil,
)

@certifcate2.crt = crt
@certifcate2.md5 = "44df9ca4e50443d1726e68beb10ca756"
@certifcate2.save!(validate: false)

Certificate.where(
    api_user: @api_user2,
    interface: "api",
).first_or_create!(
    common_name: "registrar2",
    md5: "44df9ca4e50443d1726e68beb10ca756",
    csr: nil,
    crt: crt2,
)

# Add money to all registrars
Registrar.all.each do |x|
  # Ensure the registrar has cash account
  x.accounts.where(account_type: Account::CASH, currency: 'EUR').first_or_create!

  # Add money to them
  Setting.registry_vat_prc = 0.0
  invoice = x.issue_prepayment_invoice(1337, 'add_some_money')
  bt = BankTransaction.new({ sum: 1337 })
  bt.bind_invoice(invoice.number)
  Setting.registry_vat_prc = 0.2
end

# Create pricelists for different renew/create actions for ee domain
prices = {
    "renew" => Array[3.0, 6.0, 9.0],
    "create" => Array[5.0, 10.0, 15.0]
}

prices.each do |operation_category, prices|
  prices.each_with_index do |price, i|
    pricelist = Pricelist.where(
      category: 'ee',
      operation_category: operation_category,
      duration: "#{i + 1}year",
      valid_to: nil
    ).first_or_create!

    pricelist.price = price
    pricelist.save()
  end
end
