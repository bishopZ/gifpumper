'use strict'

angular.module('gifpumper')
  .factory 'Auth', ($location, $rootScope, Session, User, $cookieStore, nowService) ->
    
    # Get currentUser from cookie
    $rootScope.currentUser = $cookieStore.get('user') or {name:'n00b'}
    $cookieStore.remove 'user'
    # $rootScope.currentUser = {name:"n00b"};
    ###
    Authenticate user
    
    @param  {Object}   user     - login info
    @param  {Function} callback - optional
    @return {Promise}
    ###

    login: (user, callback) ->
      cb = callback or angular.noop
      Session.save(
        email: user.email
        password: user.password
      , (user) ->
        $rootScope.currentUser = user
        nowService.disconnect()
        nowService.connect()
        $rootScope.loggedIn = true
        cb()
      , (err) ->
        cb err
      ).$promise

    
    ###
    Unauthenticate user
    
    @param  {Function} callback - optional
    @return {Promise}
    ###
    logout: (callback) ->
      cb = callback or angular.noop
      Session.delete(->
        $rootScope.currentUser = {name:'n00b'}
        cb()
        $cookieStore.remove 'user'
        $rootScope.$broadcast('logout')
        nowService.disconnect()
        nowService.connect()
        $rootScope.loggedIn = false
      , (err) ->
        cb err
      ).$promise

    
    ###
    Create a new user
    
    @param  {Object}   user     - user info
    @param  {Function} callback - optional
    @return {Promise}
    ###
    createUser: (user, callback) ->
      cb = callback or angular.noop
      User.save(user, (user) ->
        $rootScope.currentUser = user
        nowService.disconnect()
        nowService.connect()
        $rootScope.loggedIn = true
        cb user
      , (err) ->
        cb err
      ).$promise

    
    ###
    Change password
    
    @param  {String}   oldPassword
    @param  {String}   newPassword
    @param  {Function} callback    - optional
    @return {Promise}
    ###
    changePassword: (oldPassword, newPassword, callback) ->
      cb = callback or angular.noop
      User.update(
        oldPassword: oldPassword
        newPassword: newPassword
      , (user) ->
        cb user
      , (err) ->
        cb err
      ).$promise

    
    ###
    Gets all available info on authenticated user
    
    @return {Object} user
    ###
    currentUser: ->
      User.get()

    
    ###
    Simple check to see if a user is logged in
    
    @return {Boolean}
    ###
    isLoggedIn: ->
      user = $rootScope.currentUser
      !!user
