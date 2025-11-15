package main

import (
	"encoding/json"
	"log"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/render"
	"github.com/prometheus/alertmanager/template"
)

const (
	port = "8000"
)

type responseJSON struct {
	Status  int
	Message string
}

func main() {

	log.Printf("Listening for Alertmanager notifications, port: [%s]\n", port)

	r := chi.NewRouter()

	r.Use(middleware.RequestID)
	r.Use(middleware.Recoverer)
	r.Use(middleware.Timeout(5 * time.Second))
	r.Use(middleware.Heartbeat("/healthz"))
	r.Use(render.SetContentType(render.ContentTypeJSON))

	r.Get("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("welcome"))
	})

	r.Post("/webhook", webhook)

	// nosemgrep
	log.Fatal(http.ListenAndServe(":"+port, r))

}

func webhook(w http.ResponseWriter, r *http.Request) {

	defer r.Body.Close()

	data := template.Data{}
	if err := json.NewDecoder(r.Body).Decode(&data); err != nil {
		log.Print("Failed to process supplied payload\n")
		render.JSON(w, r, responseJSON{
			Status:  422,
			Message: "Invalid payload supplied",
		})
		return
	}

	log.Printf("Alert: GroupLabels [%v], CommonLabels [%v]", data.GroupLabels, data.CommonLabels)

	for _, alert := range data.Alerts {
		log.Printf("Alert: status=%s,Labels=%v,Annotations=%v", alert.Status, alert.Labels, alert.Annotations)
	}

	render.JSON(w, r, responseJSON{
		Status:  200,
		Message: "OK",
	})

}
