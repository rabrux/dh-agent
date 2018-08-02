###
# dark hole agent
###

# packages
Client = require 'socket.io-client'

# core libs
Keys        = require 'dh-keys'
Transaction = require './lib/_transaction'

class Agent

  constructor : ( uri, opts = {} ) ->
    # bad construction
    throw new Error 'missing params' if not opts.name or not opts.keys or not opts.exec

    # required
    @_exec   = opts.exec
    @_keys   = opts.keys
    @_lock   = false
    @_name   = opts.name
    # optional
    @_params = opts.params if opts.params

    # connect and base protocol
    @connect uri

  # connect and base protocol
  connect : ( uri ) ->
    it = @

    @socket = Client uri

    @socket.on 'connect', ->

    # server public key
    @socket.on 'keys', ( key ) ->
      it.setEncryptKey key
      @emit 'register',
        name      : it._name
        publicKey : it._keys.exportKey 'public'

    # success handshake
    @socket.on 'register:success', ( data ) ->
      console.log 'handshake:success', it._name

    # registration error
    @socket.on 'register:error', ( err ) ->
      console.error 'register:error', err
      @disconnect()

    # agent must be approved
    @socket.on 'untrusted', ->
      console.error 'handshake:error UNTRUSTED_AGENT'
      @disconnect()

    # transaction execution
    @socket.on 'exec', ( data ) ->
      it._exec data

    ###
    # hooks
    ###

    # override emit method
    _emit = @socket.emit
    @socket.emit = ->
      # crypt
      arguments[1] = it.encrypt arguments[1] if arguments[1]
      # apply
      _emit.apply it.socket, arguments

    # override onevent method
    _onevent = @socket.onevent
    @socket.onevent = ( packet ) ->
      # decrypt
      packet.data[1] = it.decrypt packet.data[1] if packet.data[1]
      # parse transaction
      packet.data[1] = new Transaction @, packet.data[1] if packet.data[0] is 'exec'
      # apply
      _onevent.call it.socket, packet

  # server public key
  setEncryptKey : ( key ) ->
    @_serverKey = Keys.from key

  # encrypt to server
  encrypt : ( data ) ->
    return @_serverKey.encrypt data, 'base64' if @_serverKey
    data

  # decrypt from server
  decrypt : ( data ) ->
    # try to decrypt json
    try
      return @_keys.decrypt data, 'json'
    catch e
      # try decrypt to text
      try
        return @_keys.decrypt data, 'utf8'
      catch e
        return data

module.exports = Agent

