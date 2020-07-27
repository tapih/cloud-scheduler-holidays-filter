package function

import (
	"context"
	"log"

	"cloud.google.com/go/pubsub"
	"github.com/kelseyhightower/envconfig"
)

type Env struct {
	ProjectID   string `envconfig:"GCP_PROJECT" required:"true"`
	TargetTopic string `envconfig:"TARGET_TOPIC" required:"true"`
}

// Filter is an Pub/Sub Cloud Function with a request parameter.
func Filter(ctx context.Context, msg *pubsub.Message) error {
	var err error
	var e Env

	err = envconfig.Process("", &e)
	if err != nil {
		return err
	}

	client, err := pubsub.NewClient(ctx, e.ProjectID)
	if err != nil {
		return err
	}

	topic := client.TopicInProject(e.TargetTopic, e.ProjectID)
	r := topic.Publish(ctx, msg)
	id, err := r.Get(ctx)
	if err != nil {
		return err
	}

	log.Printf("Published a message with a message ID: %s\n", id)
	return nil
}

// func isTodayHoliday() {
// 	today := time.Now().Format("2006-01-02")
// }
