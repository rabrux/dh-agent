class Transaction

  constructor : ( @_socket, params ) ->

    Object.assign @, params

  error : ( err ) ->
    it = @
    @_socket.emit 'end:error',
      __id : it.__id
      err  : err

  forward : ( to, next, data ) ->
    task =
      __id : @__id
      __forward : next
    Object.assign task, data
    @_socket.emit to, task

  success : ( data ) ->
    it = @
    @_socket.emit 'end:success',
      __id   : it.__id
      result : data

module.exports = Transaction

