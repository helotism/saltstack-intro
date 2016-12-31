users:
  john:
    fullname: John Doe
    #python3 -c 'import crypt; print(crypt.crypt("john2017", crypt.mksalt(crypt.METHOD_SHA512)))'
    password: $6$xjCUEpgvWTktWz18$LF8Wcsgqg4PGY5nVGT8dsgXsMzH5ZFFewCgrCcaCRCpt5S.4y8e/mShHkgLwhRAZz4DlRn5GgOuOpfscgj3AQ.
    enforce_password: True
    sudo_rules:
      - ALL=(ALL) NOPASSWD:ALL
