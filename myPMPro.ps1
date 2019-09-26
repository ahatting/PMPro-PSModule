$global:PMPinstances = @{
                    #This will be the instance friendly name
                    prod = @{ 
                                #The base URL for Password Manager Pro
                                baseURL = 'https://pmp.domain.com'
                                #The plain text authorization token OR
                                authToken = '8C720BC6-176A-4955-A050-45469552B81C'
                                #[RECOMMENDED]The encrypted API token (use pmproEncAuthToken to encrypt)
                                encToken = '01000000d08c9ddf0115d1118c7a00c04fc297eb010000000aa5c584144bac4896409970b06ee0b0000000000200000000001066000000010000200000002dc3b0aedfd3702da58ca961860f788d0e968939391425ee12d029bd479e0425000000000e800000000200002000000012865f8ee8e684649015d58b6b5a20e1292f15ec473dc9b03c59ae2dda054c5350000000aea304bed6bfce0b74a6e25af9758a809a46b1c933fb0f2d474b725ca50b114d4a9c84f70c9805ea18b9773a8b68d39bfd229d05b0433f56802bc6bef51368e43b60533ec7f78de156bc09af1b16261440000000b91b4489a1f9a1a723bf9a1de801619951de4d758834b9c407f27d0f6a30932c74f28a12bc4167cff99ce8692ad0e8ce5d06630d311482eab1b7315146dd3e53'
                            }    
                    #This will be the instance friendly name
                    test = @{ 
                        #The base URL for Password Manager Pro
                        baseURL = 'https://test-pmp.domain.com'
                        #The plain text authorization token OR
                        authToken = '8C720BC6-176A-4955-A050-45469552B81C'
                        #[RECOMMENDED]The encrypted API token (use pmproEncAuthToken to encrypt)
                        encToken = '01000000d08c9ddf0115d1118c7a00c04fc297eb010000000aa5c584144bac4896409970b06ee0b0000000000200000000001066000000010000200000002dc3b0aedfd3702da58ca961860f788d0e968939391425ee12d029bd479e0425000000000e800000000200002000000012865f8ee8e684649015d58b6b5a20e1292f15ec473dc9b03c59ae2dda054c5350000000aea304bed6bfce0b74a6e25af9758a809a46b1c933fb0f2d474b725ca50b114d4a9c84f70c9805ea18b9773a8b68d39bfd229d05b0433f56802bc6bef51368e43b60533ec7f78de156bc09af1b16261440000000b91b4489a1f9a1a723bf9a1de801619951de4d758834b9c407f27d0f6a30932c74f28a12bc4167cff99ce8692ad0e8ce5d06630d311482eab1b7315146dd3e53'
                    }   
}