// import setupState from './state'
// import setupGetters from './getters'
// import setupMutations from './mutations'
import setupActions from './actions'

const defaults = {
  namespace: 'passport',
  // state: {}, // for custom state
  // getters: {}, // for custom getters
  // mutations: {}, // for custom mutations
  actions: {} // for custom actions
}

export default feathersClient => {
  if (!feathersClient || !feathersClient.service) {
    throw new Error('You must pass a Feathers Client instance to helpers-vuex')
  }

  return function createPassportPlugin(options) {
    options = Object.assign({}, defaults, options)

    if (!feathersClient.authenticate) {
      throw new Error(
        'You must register the feathers-authentication-client plugin before using the helpers-vuex passport module'
      )
    }

    // const defaultState = setupState(options)
    // const defaultGetters = setupGetters()
    // const defaultMutations = setupMutations(feathersClient)
    const defaultActions = setupActions(feathersClient)

    return store => {
      const { namespace } = options

      store.registerModule(namespace, {
        namespaced: true,
        // state: Object.assign({}, defaultState, options.state),
        // getters: Object.assign({}, defaultGetters, options.getters),
        // mutations: Object.assign({}, defaultMutations, options.mutations),
        actions: Object.assign({}, defaultActions, options.actions)
      })
    }
  }
}
