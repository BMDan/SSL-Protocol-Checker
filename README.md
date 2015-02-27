# SSL Protocol Checker
Quickly determine which protocols and cipher suites are supported by a destination server

<pre>
$ ./checker.sh 
Usage: ./checker.sh &lt;hostname> [&lt;port>]
  &lt;port> defaults to 443 if not given.

$ ./checker.sh google.com 443
                                  ssl2      ssl3      tls1    tls1_1    tls1_2
   ECDHE-RSA-AES256-GCM-SHA384                                             √    
       ECDHE-RSA-AES256-SHA384                                             √    
          ECDHE-RSA-AES256-SHA               √         √         √         √    
             AES256-GCM-SHA384                                             √    
                 AES256-SHA256                                             √    
                    AES256-SHA               √         √         √         √    
        ECDHE-RSA-DES-CBC3-SHA               √         √         √         √    
                  DES-CBC3-SHA               √         √         √         √    
   ECDHE-RSA-AES128-GCM-SHA256                                             √    
       ECDHE-RSA-AES128-SHA256                                             √    
          ECDHE-RSA-AES128-SHA               √         √         √         √    
             AES128-GCM-SHA256                                             √    
                 AES128-SHA256                                             √    
                    AES128-SHA               √         √         √         √    
             ECDHE-RSA-RC4-SHA               √         √         √         √    
                       RC4-SHA               √         √         √         √    
                       RC4-MD5               √         √         √         √    
                       </pre>
