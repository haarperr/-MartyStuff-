Config = {}

Config.BuyPercentage = 1.0
Config.ResellPercentage = 0.7
Config.FoodItem = 'bread'
Config.Garage = {
    max = 2,
    owned = false
}

Config.Properties = {
    -- 3655 Wild Oats Drive
    -- High end house 1: -169.286 486.4938 137.4436
    {
        name = '3655 Wild Oats Drive',
        price = 1000000,
        view = {
            coords = vector3(-178.56, 502.66, 136.84),
        },
        inside = {
            coords = vector3(-174.2, 497.67, 137.67),
            heading = 188.88
        },
        outside = {
            coords = vector3(-175.46, 502.15, 137.42),
            heading = 51.9
        },
        kitchen = {
            coords = vector3(-167.03, 495.42, 137.65)
        },
        garage = {
            coords = vector3(-188.73, 500.61, 134.64),
            heading = 0.0
        },
        rooms = {
            {
                clothes = {
                    coords = vector3(-167.33, 487.49, 133.84)
                },
                cupboard = {
                    coords = vector3(-170.26, 482.09, 133.84)
                }
            },
            {
                clothes = {
                    coords = vector3(-174.88, 493.43, 130.04)
                },
                cupboard = {
                    coords = vector3(-174.83, 489.88, 130.04)
                }
            }
        }
    },
    -- 2044 North Conker Avenue
    -- High end house 2: 340.9412 437.1798 149.3925
    {
        name = '2044 North Conker Avenue',
        price = 1000000,
        view = {
            coords = vector3(350.22, 443.42, 146.94),
        },
        inside = {
            coords = vector3(341.54, 437.4, 149.39),
            heading = 121.46
        },
        outside = {
            coords = vector3(347.18, 440.88, 147.7),
            heading = 305.72
        },
        kitchen = {
            coords = vector3(341.74, 430.33, 149.38)
        },
        garage = {
            coords = vector3(352.1, 436.78, 147.25)
        },
        rooms = {
            {
                clothes = {
                    coords = vector3(334.29, 428.44, 145.57)
                },
                cupboard = {
                    coords = vector3(328.03, 429.81, 145.57)
                }
            },
            {
                clothes = {
                    coords = vector3(337.48, 437.35, 141.77)
                },
                cupboard = {
                    coords = vector3(334.29, 436.22, 141.77)
                }
            }
        }
    }
}