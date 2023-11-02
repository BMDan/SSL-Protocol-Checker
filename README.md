# SSL/TLS Protocol Checker
Quickly determine which combinations of protocols and ciphers/ciphersuites are supported by a server

```shell
$ ./checker.sh 
Usage: ./checker.sh <hostname> [<port>]
  <port> defaults to 443 if not given.

$ ./checker.sh google.com
                                  tls1    tls1_1    tls1_2    tls1_3
        TLS_AES_256_GCM_SHA384                                   √
  TLS_CHACHA20_POLY1305_SHA256                                   √
        TLS_AES_128_GCM_SHA256                                   √
 ECDHE-ECDSA-AES256-GCM-SHA384                         √
   ECDHE-RSA-AES256-GCM-SHA384                         √
 ECDHE-ECDSA-CHACHA20-POLY1305                         √
   ECDHE-RSA-CHACHA20-POLY1305                         √
 ECDHE-ECDSA-AES128-GCM-SHA256                         √
   ECDHE-RSA-AES128-GCM-SHA256                         √
        ECDHE-ECDSA-AES256-SHA                         √
          ECDHE-RSA-AES256-SHA                         √
        ECDHE-ECDSA-AES128-SHA                         √
          ECDHE-RSA-AES128-SHA                         √
             AES256-GCM-SHA384                         √
             AES128-GCM-SHA256                         √
                    AES256-SHA                         √
                    AES128-SHA                         √
```

For comparison, in 2018, this same tool produced this output when run against google.com:
```shell
                                  ssl2      ssl3      tls1    tls1_1    tls1_2
   ECDHE-RSA-AES256-GCM-SHA384                                             √
          ECDHE-RSA-AES256-SHA                         √         √         √
             AES256-GCM-SHA384                                             √
                    AES256-SHA                         √         √         √
   ECDHE-RSA-AES128-GCM-SHA256                                             √
          ECDHE-RSA-AES128-SHA                         √         √         √
             AES128-GCM-SHA256                                             √
                    AES128-SHA                         √         √         √
                  DES-CBC3-SHA                         √         √         √
```

## How it works

The list of candidate protocols is winnowed down to only those supported by your local copy of `openssl(1)`.  The full list of candidate ciphers is produced by running `openssl ciphers ALL:COMPLEMENTOFALL`.  Then, each cipher/protocol combination is attempted using `openssl s_client`.

The full list of ciphers and protocols checked will thus depend on your `openssl` version.  An example list is provided at the bottom of this document.

Note that only ciphers which successfully connect under at least one protocol will be printed.

## Differences in output compared to other tools

### Ciphersuites

Many other tools, especially older ones, misrepresent what ciphers are supported by a server, especially under TLS 1.3 and above.  That's because openssl silently ignores `-cipher` in TLSv1.3 mode.  Even absurd ciphers will appear to connect; `openssl s_client -cipher NULL-MD5 -tls1_3 -connect google.com:443` ostensibly works!  Of course, if you look under the hood, you'll see that the cipher it used was `TLS_AES_256_GCM_SHA384`, which is perfectly acceptable.

In TLSv1.3, only `-ciphersuites` has any effect.  Conversely, when using older versions of TLS or SSL, `-ciphersuites` is silently ignored.

### Reporting

Please report any other differences to the maintainer.

## See Also (Similar Tools)

* [sslscan](https://github.com/rbsec/sslscan/blob/master/sslscan.c)

## Example Cipher/Ciphersuite List

The most recent output of this tool quoted in this README was produced using v3.3.0-dev of the OpenSSL application.  The tool attempted to connect using each of the following:

<details>
<summary>Example list of ciphers</summary>

| OpenSSL Cipher[-suite?] Name   | Standard Name (as reported by `-stdname`)     | Min. Version |
|--------------------------------|-----------------------------------------------|---------|
| TLS_CHACHA20_POLY1305_SHA256   | TLS_CHACHA20_POLY1305_SHA256                  | TLSv1.3 |
| TLS_AES_256_GCM_SHA384         | TLS_AES_256_GCM_SHA384                        | TLSv1.3 |
| TLS_AES_128_GCM_SHA256         | TLS_AES_128_GCM_SHA256                        | TLSv1.3 |
| ECDHE-ECDSA-CHACHA20-POLY1305  | TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256 | TLSv1.2 |
| ECDHE-ECDSA-CAMELLIA256-SHA384 | TLS_ECDHE_ECDSA_WITH_CAMELLIA_256_CBC_SHA384  | TLSv1.2 |
| ECDHE-ECDSA-CAMELLIA128-SHA256 | TLS_ECDHE_ECDSA_WITH_CAMELLIA_128_CBC_SHA256  | TLSv1.2 |
| ECDHE-RSA-CHACHA20-POLY1305    | TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256   | TLSv1.2 |
| ECDHE-PSK-CHACHA20-POLY1305    | TLS_ECDHE_PSK_WITH_CHACHA20_POLY1305_SHA256   | TLSv1.2 |
| ECDHE-RSA-CAMELLIA256-SHA384   | TLS_ECDHE_RSA_WITH_CAMELLIA_256_CBC_SHA384    | TLSv1.2 |
| ECDHE-RSA-CAMELLIA128-SHA256   | TLS_ECDHE_RSA_WITH_CAMELLIA_128_CBC_SHA256    | TLSv1.2 |
| RSA-PSK-CHACHA20-POLY1305      | TLS_RSA_PSK_WITH_CHACHA20_POLY1305_SHA256     | TLSv1.2 |
| DHE-RSA-CHACHA20-POLY1305      | TLS_DHE_RSA_WITH_CHACHA20_POLY1305_SHA256     | TLSv1.2 |
| DHE-PSK-CHACHA20-POLY1305      | TLS_DHE_PSK_WITH_CHACHA20_POLY1305_SHA256     | TLSv1.2 |
| ECDHE-ECDSA-ARIA256-GCM-SHA384 | TLS_ECDHE_ECDSA_WITH_ARIA_256_GCM_SHA384      | TLSv1.2 |
| ECDHE-ECDSA-ARIA128-GCM-SHA256 | TLS_ECDHE_ECDSA_WITH_ARIA_128_GCM_SHA256      | TLSv1.2 |
| DHE-RSA-CAMELLIA256-SHA256     | TLS_DHE_RSA_WITH_CAMELLIA_256_CBC_SHA256      | TLSv1.2 |
| DHE-RSA-CAMELLIA128-SHA256     | TLS_DHE_RSA_WITH_CAMELLIA_128_CBC_SHA256      | TLSv1.2 |
| DHE-DSS-CAMELLIA256-SHA256     | TLS_DHE_DSS_WITH_CAMELLIA_256_CBC_SHA256      | TLSv1.2 |
| DHE-DSS-CAMELLIA128-SHA256     | TLS_DHE_DSS_WITH_CAMELLIA_128_CBC_SHA256      | TLSv1.2 |
| ADH-CAMELLIA256-SHA256         | TLS_DH_anon_WITH_CAMELLIA_256_CBC_SHA256      | TLSv1.2 |
| ADH-CAMELLIA128-SHA256         | TLS_DH_anon_WITH_CAMELLIA_128_CBC_SHA256      | TLSv1.2 |
| ECDHE-ECDSA-AES256-SHA384      | TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384       | TLSv1.2 |
| ECDHE-ECDSA-AES256-GCM-SHA384  | TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384       | TLSv1.2 |
| ECDHE-ECDSA-AES128-SHA256      | TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256       | TLSv1.2 |
| ECDHE-ECDSA-AES128-GCM-SHA256  | TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256       | TLSv1.2 |
| ECDHE-ARIA256-GCM-SHA384       | TLS_ECDHE_RSA_WITH_ARIA_256_GCM_SHA384        | TLSv1.2 |
| ECDHE-ARIA128-GCM-SHA256       | TLS_ECDHE_RSA_WITH_ARIA_128_GCM_SHA256        | TLSv1.2 |
| PSK-CHACHA20-POLY1305          | TLS_PSK_WITH_CHACHA20_POLY1305_SHA256         | TLSv1.2 |
| ECDHE-RSA-AES256-SHA384        | TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384         | TLSv1.2 |
| ECDHE-RSA-AES256-GCM-SHA384    | TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384         | TLSv1.2 |
| ECDHE-RSA-AES128-SHA256        | TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256         | TLSv1.2 |
| ECDHE-RSA-AES128-GCM-SHA256    | TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256         | TLSv1.2 |
| RSA-PSK-ARIA256-GCM-SHA384     | TLS_RSA_PSK_WITH_ARIA_256_GCM_SHA384          | TLSv1.2 |
| RSA-PSK-ARIA128-GCM-SHA256     | TLS_RSA_PSK_WITH_ARIA_128_GCM_SHA256          | TLSv1.2 |
| DHE-RSA-ARIA256-GCM-SHA384     | TLS_DHE_RSA_WITH_ARIA_256_GCM_SHA384          | TLSv1.2 |
| DHE-RSA-ARIA128-GCM-SHA256     | TLS_DHE_RSA_WITH_ARIA_128_GCM_SHA256          | TLSv1.2 |
| DHE-PSK-ARIA256-GCM-SHA384     | TLS_DHE_PSK_WITH_ARIA_256_GCM_SHA384          | TLSv1.2 |
| DHE-PSK-ARIA128-GCM-SHA256     | TLS_DHE_PSK_WITH_ARIA_128_GCM_SHA256          | TLSv1.2 |
| DHE-DSS-ARIA256-GCM-SHA384     | TLS_DHE_DSS_WITH_ARIA_256_GCM_SHA384          | TLSv1.2 |
| DHE-DSS-ARIA128-GCM-SHA256     | TLS_DHE_DSS_WITH_ARIA_128_GCM_SHA256          | TLSv1.2 |
| CAMELLIA256-SHA256             | TLS_RSA_WITH_CAMELLIA_256_CBC_SHA256          | TLSv1.2 |
| CAMELLIA128-SHA256             | TLS_RSA_WITH_CAMELLIA_128_CBC_SHA256          | TLSv1.2 |
| RSA-PSK-AES256-GCM-SHA384      | TLS_RSA_PSK_WITH_AES_256_GCM_SHA384           | TLSv1.2 |
| RSA-PSK-AES128-GCM-SHA256      | TLS_RSA_PSK_WITH_AES_128_GCM_SHA256           | TLSv1.2 |
| DHE-RSA-AES256-SHA256          | TLS_DHE_RSA_WITH_AES_256_CBC_SHA256           | TLSv1.2 |
| DHE-RSA-AES256-GCM-SHA384      | TLS_DHE_RSA_WITH_AES_256_GCM_SHA384           | TLSv1.2 |
| DHE-RSA-AES128-SHA256          | TLS_DHE_RSA_WITH_AES_128_CBC_SHA256           | TLSv1.2 |
| DHE-RSA-AES128-GCM-SHA256      | TLS_DHE_RSA_WITH_AES_128_GCM_SHA256           | TLSv1.2 |
| DHE-PSK-AES256-GCM-SHA384      | TLS_DHE_PSK_WITH_AES_256_GCM_SHA384           | TLSv1.2 |
| DHE-PSK-AES128-GCM-SHA256      | TLS_DHE_PSK_WITH_AES_128_GCM_SHA256           | TLSv1.2 |
| DHE-DSS-AES256-SHA256          | TLS_DHE_DSS_WITH_AES_256_CBC_SHA256           | TLSv1.2 |
| DHE-DSS-AES256-GCM-SHA384      | TLS_DHE_DSS_WITH_AES_256_GCM_SHA384           | TLSv1.2 |
| DHE-DSS-AES128-SHA256          | TLS_DHE_DSS_WITH_AES_128_CBC_SHA256           | TLSv1.2 |
| DHE-DSS-AES128-GCM-SHA256      | TLS_DHE_DSS_WITH_AES_128_GCM_SHA256           | TLSv1.2 |
| ADH-AES256-SHA256              | TLS_DH_anon_WITH_AES_256_CBC_SHA256           | TLSv1.2 |
| ADH-AES256-GCM-SHA384          | TLS_DH_anon_WITH_AES_256_GCM_SHA384           | TLSv1.2 |
| ADH-AES128-SHA256              | TLS_DH_anon_WITH_AES_128_CBC_SHA256           | TLSv1.2 |
| ADH-AES128-GCM-SHA256          | TLS_DH_anon_WITH_AES_128_GCM_SHA256           | TLSv1.2 |
| ECDHE-ECDSA-AES256-CCM8        | TLS_ECDHE_ECDSA_WITH_AES_256_CCM_8            | TLSv1.2 |
| ECDHE-ECDSA-AES128-CCM8        | TLS_ECDHE_ECDSA_WITH_AES_128_CCM_8            | TLSv1.2 |
| PSK-ARIA256-GCM-SHA384         | TLS_PSK_WITH_ARIA_256_GCM_SHA384              | TLSv1.2 |
| PSK-ARIA128-GCM-SHA256         | TLS_PSK_WITH_ARIA_128_GCM_SHA256              | TLSv1.2 |
| ECDHE-ECDSA-AES256-CCM         | TLS_ECDHE_ECDSA_WITH_AES_256_CCM              | TLSv1.2 |
| ECDHE-ECDSA-AES128-CCM         | TLS_ECDHE_ECDSA_WITH_AES_128_CCM              | TLSv1.2 |
| ARIA256-GCM-SHA384             | TLS_RSA_WITH_ARIA_256_GCM_SHA384              | TLSv1.2 |
| ARIA128-GCM-SHA256             | TLS_RSA_WITH_ARIA_128_GCM_SHA256              | TLSv1.2 |
| PSK-AES256-GCM-SHA384          | TLS_PSK_WITH_AES_256_GCM_SHA384               | TLSv1.2 |
| PSK-AES128-GCM-SHA256          | TLS_PSK_WITH_AES_128_GCM_SHA256               | TLSv1.2 |
| AES256-SHA256                  | TLS_RSA_WITH_AES_256_CBC_SHA256               | TLSv1.2 |
| AES256-GCM-SHA384              | TLS_RSA_WITH_AES_256_GCM_SHA384               | TLSv1.2 |
| AES128-SHA256                  | TLS_RSA_WITH_AES_128_CBC_SHA256               | TLSv1.2 |
| AES128-GCM-SHA256              | TLS_RSA_WITH_AES_128_GCM_SHA256               | TLSv1.2 |
| DHE-RSA-AES256-CCM8            | TLS_DHE_RSA_WITH_AES_256_CCM_8                | TLSv1.2 |
| DHE-RSA-AES128-CCM8            | TLS_DHE_RSA_WITH_AES_128_CCM_8                | TLSv1.2 |
| DHE-PSK-AES256-CCM8            | TLS_PSK_DHE_WITH_AES_256_CCM_8                | TLSv1.2 |
| DHE-PSK-AES128-CCM8            | TLS_PSK_DHE_WITH_AES_128_CCM_8                | TLSv1.2 |
| DHE-RSA-AES256-CCM             | TLS_DHE_RSA_WITH_AES_256_CCM                  | TLSv1.2 |
| DHE-RSA-AES128-CCM             | TLS_DHE_RSA_WITH_AES_128_CCM                  | TLSv1.2 |
| DHE-PSK-AES256-CCM             | TLS_DHE_PSK_WITH_AES_256_CCM                  | TLSv1.2 |
| DHE-PSK-AES128-CCM             | TLS_DHE_PSK_WITH_AES_128_CCM                  | TLSv1.2 |
| PSK-AES256-CCM8                | TLS_PSK_WITH_AES_256_CCM_8                    | TLSv1.2 |
| PSK-AES128-CCM8                | TLS_PSK_WITH_AES_128_CCM_8                    | TLSv1.2 |
| AES256-CCM8                    | TLS_RSA_WITH_AES_256_CCM_8                    | TLSv1.2 |
| AES128-CCM8                    | TLS_RSA_WITH_AES_128_CCM_8                    | TLSv1.2 |
| PSK-AES256-CCM                 | TLS_PSK_WITH_AES_256_CCM                      | TLSv1.2 |
| PSK-AES128-CCM                 | TLS_PSK_WITH_AES_128_CCM                      | TLSv1.2 |
| NULL-SHA256                    | TLS_RSA_WITH_NULL_SHA256                      | TLSv1.2 |
| AES256-CCM                     | TLS_RSA_WITH_AES_256_CCM                      | TLSv1.2 |
| AES128-CCM                     | TLS_RSA_WITH_AES_128_CCM                      | TLSv1.2 |
| ECDHE-PSK-CAMELLIA256-SHA384   | TLS_ECDHE_PSK_WITH_CAMELLIA_256_CBC_SHA384    | TLSv1 |
| ECDHE-PSK-CAMELLIA128-SHA256   | TLS_ECDHE_PSK_WITH_CAMELLIA_128_CBC_SHA256    | TLSv1 |
| RSA-PSK-CAMELLIA256-SHA384     | TLS_RSA_PSK_WITH_CAMELLIA_256_CBC_SHA384      | TLSv1 |
| RSA-PSK-CAMELLIA128-SHA256     | TLS_RSA_PSK_WITH_CAMELLIA_128_CBC_SHA256      | TLSv1 |
| DHE-PSK-CAMELLIA256-SHA384     | TLS_DHE_PSK_WITH_CAMELLIA_256_CBC_SHA384      | TLSv1 |
| DHE-PSK-CAMELLIA128-SHA256     | TLS_DHE_PSK_WITH_CAMELLIA_128_CBC_SHA256      | TLSv1 |
| ECDHE-PSK-AES256-CBC-SHA384    | TLS_ECDHE_PSK_WITH_AES_256_CBC_SHA384         | TLSv1 |
| ECDHE-PSK-AES128-CBC-SHA256    | TLS_ECDHE_PSK_WITH_AES_128_CBC_SHA256         | TLSv1 |
| PSK-CAMELLIA256-SHA384         | TLS_PSK_WITH_CAMELLIA_256_CBC_SHA384          | TLSv1 |
| PSK-CAMELLIA128-SHA256         | TLS_PSK_WITH_CAMELLIA_128_CBC_SHA256          | TLSv1 |
| ECDHE-ECDSA-AES256-SHA         | TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA          | TLSv1 |
| ECDHE-ECDSA-AES128-SHA         | TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA          | TLSv1 |
| RSA-PSK-AES256-CBC-SHA384      | TLS_RSA_PSK_WITH_AES_256_CBC_SHA384           | TLSv1 |
| RSA-PSK-AES128-CBC-SHA256      | TLS_RSA_PSK_WITH_AES_128_CBC_SHA256           | TLSv1 |
| DHE-PSK-AES256-CBC-SHA384      | TLS_DHE_PSK_WITH_AES_256_CBC_SHA384           | TLSv1 |
| DHE-PSK-AES128-CBC-SHA256      | TLS_DHE_PSK_WITH_AES_128_CBC_SHA256           | TLSv1 |
| ECDHE-RSA-AES256-SHA           | TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA            | TLSv1 |
| ECDHE-RSA-AES128-SHA           | TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA            | TLSv1 |
| ECDHE-PSK-AES256-CBC-SHA       | TLS_ECDHE_PSK_WITH_AES_256_CBC_SHA            | TLSv1 |
| ECDHE-PSK-AES128-CBC-SHA       | TLS_ECDHE_PSK_WITH_AES_128_CBC_SHA            | TLSv1 |
| AECDH-AES256-SHA               | TLS_ECDH_anon_WITH_AES_256_CBC_SHA            | TLSv1 |
| AECDH-AES128-SHA               | TLS_ECDH_anon_WITH_AES_128_CBC_SHA            | TLSv1 |
| PSK-AES256-CBC-SHA384          | TLS_PSK_WITH_AES_256_CBC_SHA384               | TLSv1 |
| PSK-AES128-CBC-SHA256          | TLS_PSK_WITH_AES_128_CBC_SHA256               | TLSv1 |
| ECDHE-PSK-NULL-SHA384          | TLS_ECDHE_PSK_WITH_NULL_SHA384                | TLSv1 |
| ECDHE-PSK-NULL-SHA256          | TLS_ECDHE_PSK_WITH_NULL_SHA256                | TLSv1 |
| ECDHE-ECDSA-NULL-SHA           | TLS_ECDHE_ECDSA_WITH_NULL_SHA                 | TLSv1 |
| RSA-PSK-NULL-SHA384            | TLS_RSA_PSK_WITH_NULL_SHA384                  | TLSv1 |
| RSA-PSK-NULL-SHA256            | TLS_RSA_PSK_WITH_NULL_SHA256                  | TLSv1 |
| DHE-PSK-NULL-SHA384            | TLS_DHE_PSK_WITH_NULL_SHA384                  | TLSv1 |
| DHE-PSK-NULL-SHA256            | TLS_DHE_PSK_WITH_NULL_SHA256                  | TLSv1 |
| ECDHE-RSA-NULL-SHA             | TLS_ECDHE_RSA_WITH_NULL_SHA                   | TLSv1 |
| ECDHE-PSK-NULL-SHA             | TLS_ECDHE_PSK_WITH_NULL_SHA                   | TLSv1 |
| AECDH-NULL-SHA                 | TLS_ECDH_anon_WITH_NULL_SHA                   | TLSv1 |
| PSK-NULL-SHA384                | TLS_PSK_WITH_NULL_SHA384                      | TLSv1 |
| PSK-NULL-SHA256                | TLS_PSK_WITH_NULL_SHA256                      | TLSv1 |
| DHE-RSA-CAMELLIA256-SHA        | TLS_DHE_RSA_WITH_CAMELLIA_256_CBC_SHA         | SSLv3 |
| DHE-RSA-CAMELLIA128-SHA        | TLS_DHE_RSA_WITH_CAMELLIA_128_CBC_SHA         | SSLv3 |
| DHE-DSS-CAMELLIA256-SHA        | TLS_DHE_DSS_WITH_CAMELLIA_256_CBC_SHA         | SSLv3 |
| DHE-DSS-CAMELLIA128-SHA        | TLS_DHE_DSS_WITH_CAMELLIA_128_CBC_SHA         | SSLv3 |
| ADH-CAMELLIA256-SHA            | TLS_DH_anon_WITH_CAMELLIA_256_CBC_SHA         | SSLv3 |
| ADH-CAMELLIA128-SHA            | TLS_DH_anon_WITH_CAMELLIA_128_CBC_SHA         | SSLv3 |
| SRP-RSA-AES-256-CBC-SHA        | TLS_SRP_SHA_RSA_WITH_AES_256_CBC_SHA          | SSLv3 |
| SRP-RSA-AES-128-CBC-SHA        | TLS_SRP_SHA_RSA_WITH_AES_128_CBC_SHA          | SSLv3 |
| SRP-DSS-AES-256-CBC-SHA        | TLS_SRP_SHA_DSS_WITH_AES_256_CBC_SHA          | SSLv3 |
| SRP-DSS-AES-128-CBC-SHA        | TLS_SRP_SHA_DSS_WITH_AES_128_CBC_SHA          | SSLv3 |
| CAMELLIA256-SHA                | TLS_RSA_WITH_CAMELLIA_256_CBC_SHA             | SSLv3 |
| CAMELLIA128-SHA                | TLS_RSA_WITH_CAMELLIA_128_CBC_SHA             | SSLv3 |
| SRP-AES-256-CBC-SHA            | TLS_SRP_SHA_WITH_AES_256_CBC_SHA              | SSLv3 |
| SRP-AES-128-CBC-SHA            | TLS_SRP_SHA_WITH_AES_128_CBC_SHA              | SSLv3 |
| RSA-PSK-AES256-CBC-SHA         | TLS_RSA_PSK_WITH_AES_256_CBC_SHA              | SSLv3 |
| RSA-PSK-AES128-CBC-SHA         | TLS_RSA_PSK_WITH_AES_128_CBC_SHA              | SSLv3 |
| DHE-RSA-AES256-SHA             | TLS_DHE_RSA_WITH_AES_256_CBC_SHA              | SSLv3 |
| DHE-RSA-AES128-SHA             | TLS_DHE_RSA_WITH_AES_128_CBC_SHA              | SSLv3 |
| DHE-PSK-AES256-CBC-SHA         | TLS_DHE_PSK_WITH_AES_256_CBC_SHA              | SSLv3 |
| DHE-PSK-AES128-CBC-SHA         | TLS_DHE_PSK_WITH_AES_128_CBC_SHA              | SSLv3 |
| DHE-DSS-AES256-SHA             | TLS_DHE_DSS_WITH_AES_256_CBC_SHA              | SSLv3 |
| DHE-DSS-AES128-SHA             | TLS_DHE_DSS_WITH_AES_128_CBC_SHA              | SSLv3 |
| ADH-AES256-SHA                 | TLS_DH_anon_WITH_AES_256_CBC_SHA              | SSLv3 |
| ADH-AES128-SHA                 | TLS_DH_anon_WITH_AES_128_CBC_SHA              | SSLv3 |
| PSK-AES256-CBC-SHA             | TLS_PSK_WITH_AES_256_CBC_SHA                  | SSLv3 |
| PSK-AES128-CBC-SHA             | TLS_PSK_WITH_AES_128_CBC_SHA                  | SSLv3 |
| AES256-SHA                     | TLS_RSA_WITH_AES_256_CBC_SHA                  | SSLv3 |
| AES128-SHA                     | TLS_RSA_WITH_AES_128_CBC_SHA                  | SSLv3 |
| RSA-PSK-NULL-SHA               | TLS_RSA_PSK_WITH_NULL_SHA                     | SSLv3 |
| DHE-PSK-NULL-SHA               | TLS_DHE_PSK_WITH_NULL_SHA                     | SSLv3 |
| PSK-NULL-SHA                   | TLS_PSK_WITH_NULL_SHA                         | SSLv3 |
| NULL-SHA                       | TLS_RSA_WITH_NULL_SHA                         | SSLv3 |
| NULL-MD5                       | TLS_RSA_WITH_NULL_MD5                         | SSLv3 |
</details>
