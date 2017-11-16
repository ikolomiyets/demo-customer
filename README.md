# Demo Customers Project

Serves a single endpoint at GET `/customers/:customerId` where customer Id is an integer value.
Since it is serving the static content hardcoded internally, service only recognizes the customerId 
* 1
* 2
* 4
* 16

Other IDs will fail!

## Building the image

In order to build the image run the following

```docker build -t demo-customer .```

## Starting the Demo Frontend container

You can start the Demo Customer container using the following command:

```docker run --name demo-customer --network sandbox demo-customer```

The above command assumes that network sandbox exists in your docker environment.

If not it could be created with the following command:

```docker network create sandbox```
