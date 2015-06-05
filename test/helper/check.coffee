# helper method that catches errors in ansynchronous tests
check = (done, callback) ->
  try
    callback()
    done()
  catch err
    return done(err)

module.exports = check