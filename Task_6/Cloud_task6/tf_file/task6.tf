provider "kubernetes" {
    config_context_cluster   = "minikube"
}
resource "kubernetes_deployment" "webapp" {
  metadata {
    name = "wordpress"
  }
  spec {


    replicas = 3
    
    selector{
    match_labels = {
      env = "Development"
      dc = "IN"
      App = "wordpress"
    }
    match_expressions {
      key = "env"
      operator = "In"
      values = ["Development" , "wordpress"]
    }
  }
   template {
        metadata {
         labels = {
      env = "Development"
      dc = "IN"
      App = "wordpress"
    }
        }


      spec {
        container {
          image = "wordpress:4.8-apache"
          name  = "cont"


        }
      }
    }
}
}
resource "kubernetes_service" "service" {
  metadata {
    name = "loadbalancer"
  }
  spec {
    selector = {
      App = kubernetes_deployment.webapp.spec.0.template.0.metadata[0].labels.App
    }
    port {
      node_port   = 31000
      port        = 80
      target_port = 80
    }
    type = "NodePort"
} 
}
