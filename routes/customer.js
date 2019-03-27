const express = require('express');
const router = express.Router();

const customers = {
    1: {
        firstName: 'Sarah',
        lastName: 'Brennan',
        address: 'Croom, Co. Limerick'
    },
    2: {
        firstName: 'Eva',
        lastName: 'Olson',
        address: '3, Patrick st, Limerick'
    },
    4: {
        firstName: 'James',
        lastName: 'Brennan',
        address: 'Croom, Co. Limerick'
    },
    16: {
        firstName: 'Dermot',
        lastName: 'Finnegan',
        address: 'Anacotty, Co. Limeric'
    }
};
/* GET users listing. */
router.get('/customers/:customerId', function(req, res, next) {
    const customerId = req.params['customerId'];
    res.header('Content-Type', 'application/json');
    res.header('Access-Control-Allow-Origin', '*');
    res.json(customers[customerId]);
});

module.exports = router;
