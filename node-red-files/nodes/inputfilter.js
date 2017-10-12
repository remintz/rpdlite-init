module.exports = function (RED) {

   function inputFilterNode(config) {
      RED.nodes.createNode(this, config);
      var node = this;
      var context = this.context();
      var globalContext = this.context().global;
      var hostname = globalContext.get('os').hostname();
      this.on('input', function (msg) {

         // Convert input into JSON message if necessary
         try {
            if (typeof msg.payload === 'string' || msg.payload instanceof String) msg.payload = JSON.parse(msg.payload);
         }
         catch (err) {
            node.warn("Failed to test the type of msg.payload or failed to convert into a JSON object");
            node.send(null);
            return;
         }

         var getvalue = config.getvalue || false;

         if (!msg.payload.device) {
            node.warn("device field not found on payload");
            node.send(null);
            return;
         }
         if (!msg.payload.type) {
            node.warn("device type not found on payload");
            node.send(null);
            return;
         }
         if (!msg.payload.address) {
            node.warn("device address not found on payload");
            node.send(null);
            return;
         }

         // if gateway name is left blank it defaults to the edge controller hostname
         
         var gateway = config.gateway;
         if (!gateway) {
            gateway = hostname;
         }
         if (!gateway) {
            gateway = "";
         }

         var pass = true;

         if ((gateway.trim().length > 0) && (gateway.trim() != msg.payload.device.trim()) && (gateway.trim() != "*")) {
            pass = false;
         }

         if ((config.porttype.trim().length != 0) && (msg.payload.type.trim() != config.porttype.trim()) && (config.porttype.trim() != "*")) {
            pass = false;
         }

         if ((config.address.trim().length != 0) && (msg.payload.address.trim() != config.address.trim())) {
            pass = false;
         }

         if (pass) {
            if (getvalue) {
               msg.payload = msg.payload.value;
            }
            node.send(msg)
         } else {
            node.send(null)
         }
      });
   }
   RED.nodes.registerType("input-filter", inputFilterNode);
}

