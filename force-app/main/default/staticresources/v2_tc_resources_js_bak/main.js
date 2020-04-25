TC = {
      version: 0.1,
      author: 'MyTrueCost.com',
      app: {},
      scrollMagic: {},
      api: {},
      cms: [],
      dom: {},
      fn: {setup: {}},
      account: {},
      sf: {resource: {}}
    };
    
    TC.routes = { 
        esidComplete: '/apex/Lookup_ESID_Complete',
        accountMoving: '/apex/Account_Moving',
        accountSchedule: '/apex/Account_Schedule',
        accountDetails: '/apex/Account_Details',
        shopPlans: '/apex/Shop_Plans'
    };
    TC.sf.resource = { images: '{!URLFOR($Resource.v2_tc_resources_images)}' + '/' }
    
    TC.scrollMagic.controller = new ScrollMagic.Controller();
    
    TC.fn.navigateTo = function(path){
        window.location.href = path;
    };
    
    TC.fn.setup.ZipInput = function () {
      $('.field input').on('focus', function (e) {
        $(e.currentTarget.parentElement).find('label').css('opacity', 0)
      });
      $('.field input').on('blur', function (e) {
        if ($(e.currentTarget).val() <= 0) {
          $(e.currentTarget.parentElement).find('label').css('opacity', 1)
        }
      });
    };
    
    TC.app.account = new Vue({
      el: '#account',
      data: {
          leadId: sessionStorage.getItem('leadId'),
          email: sessionStorage.getItem('email'),
          firstName: sessionStorage.getItem('firstName'),
          lastName: sessionStorage.getItem('lastName'),
          phone: sessionStorage.getItem('phone'),
          ssn: sessionStorage.getItem('ssn'),
          dob: sessionStorage.getItem('dob'),
          phoneSMS: '',
          optIn: '',
          plan: {},
          plansCompare: [],
          premise: {
            type: sessionStorage.getItem('premiseType'),
            id: sessionStorage.getItem('premisId'),
            esid: sessionStorage.getItem('esid'),
            street: sessionStorage.getItem('street'),
            city: sessionStorage.getItem('city'),
            state: sessionStorage.getItem('state'),
            zip: sessionStorage.getItem('zip'),
            recordId: '',
            serviceType: sessionStorage.getItem('serviceType'),
          }
      },
      methods: {
        setAccount() {
        },
      },
      mounted() {
      },
      watch: {
        firstName: {
          handler() {
            sessionStorage.setItem('firstName', this.firstName);
          },
        },
        lastName: {
          handler() {
            sessionStorage.setItem('lastName', this.lastName);
          },
        },
        email: {
          handler() {
            sessionStorage.setItem('email', this.email);
          },
        },
        phone: {
          handler() {
            sessionStorage.setItem('phone', this.phone);
          },
        },
        dob: {
          handler() {
            sessionStorage.setItem('dob', this.dob);
          },
        },
        ssn: {
          handler() {
            sessionStorage.setItem('ssn', this.ssn);
          },
        },
        plansCompare: {
          handler() {
            sessionStorage.setItem('plansCompare', JSON.stringify(this.plansCompare));
          },
        },
        plan: {
          handler() {
            sessionStorage.setItem('plan', JSON.stringify(this.plan));
          },
        },
        'premise.type': {
          handler() {
            sessionStorage.setItem('type', this.premise.type);
          },
        },
        'premise.id': {
          handler() {
            sessionStorage.setItem('premiseId', this.premise.id);
          },
        },
        'premise.esid': {
          handler() {
            sessionStorage.setItem('esid', this.premise.esid);
          },
        },
        'premise.street': {
          handler() {
            sessionStorage.setItem('street', this.premise.street);
          },
        },
        'premise.city': {
          handler() {
            sessionStorage.setItem('city', this.premise.city);
          },
        },
        'premise.state': {
          handler() {
            sessionStorage.setItem('state', this.premise.state);
          },
        },
        'premise.zip': {
          handler() {
            sessionStorage.setItem('zip', this.premise.zip);
          },
        },
        'premise.serviceType': {
          handler() {
            sessionStorage.setItem('serviceType', this.premise.serviceType);
          },
        },
        
      },
    });
        
    TC.fn.openTab = function (evt, tabName) {

      var i, tabcontent, tablinks;

      tabcontent = document.getElementsByClassName("tabcontent");
      for (i = 0; i < tabcontent.length; i++) {
        tabcontent[i].style.display = "none";
      }

      tablinks = document.getElementsByClassName("tablinks");
      for (i = 0; i < tablinks.length; i++) {
        tablinks[i].className = tablinks[i].className.replace(" is-active", "");
      }

      document.getElementById(tabName).style.display = "block";
      evt.currentTarget.className += " is-active";
    }

    TC.fn.openCustomTab = function (evt, tabName) {
      var i, tabcontent, tablinks;

      tablinks = document.getElementsByClassName("tablinks");
      for (i = 0; i < tablinks.length; i++) {
        tablinks[i].className = tablinks[i].className.replace(" is-active", "");
      }

      document.getElementById(tabName).style.display = "block";
      evt.currentTarget.className += " is-active";
    }

    TC.app.myzip = new Vue({
      el: '#appZip',
      data: {
        zip: '',
        newZip: '',
      },
      methods: {
        changeZip() {
          this.zip = this.newZip;
          this.newZip = '';
        },
      },
      mounted() {
        console.log('AppZip mounted!');
        if (sessionStorage.getItem('search_zip')) this.zip = JSON.parse(sessionStorage.getItem('search_zip'));
      },
      watch: {
        zip: {
          handler() {
            console.log('Zip changed!');
            sessionStorage.setItem('search_zip', JSON.stringify(this.zip));
          },
          deep: true,
        },
      },
    });

    TC.app.homeProfile = new Vue({
      el: '#appHomeProfile',
      data: {
        squarefootage: '',
        yearbuilt: '',
        heatingsystem: '',
        pool: '',
        occupants: 0,
        houseSize: '',
      },
      methods: {},
      mounted() {
        console.log('AppHomeProfile mounted!');
      },
      watch: {
        squarefootage: {
          handler() {
            sessionStorage.setItem('squarefootage', JSON.stringify(this.squarefootage));
          },
        },
        yearbuilt: {
          handler() {
            sessionStorage.setItem('yearbuilt', JSON.stringify(this.yearbuilt));
          },
        },
        heatingsystem: {
          handler() {
            sessionStorage.setItem('heatingsystem', JSON.stringify(this.heatingsystem));
          },
        },
        pool: {
          handler() {
            sessionStorage.setItem('pool', JSON.stringify(this.pool));
          },
        },
        occupants: {
          handler() {
            sessionStorage.setItem('occupants', JSON.stringify(this.occupants));
          },
        },
        houseSize: {
          handler() {
            sessionStorage.setItem('houseSize', JSON.stringify(this.houseSize));
          },
        },
      },
    });

    TC.fn.initialize = function () {
      TC.fn.setup.ZipInput();
    };

    (function ($) {
      $(function () {
        'use strict';
        TC.fn.initialize();
      })
    })(jQuery);
