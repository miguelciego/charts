package main

import (
	"regexp"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/stretchr/testify/require"
	appsV1 "k8s.io/api/apps/v1"
	coreV1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/util/intstr"
)

const (
	chartName     = "auto-deploy-app-2.3.0"
	helmChartPath = ".."
)

func renderTemplate(t *testing.T, values map[string]string, releaseName string, templates []string, expectedErrorRegexp *regexp.Regexp) (string, bool) {
	opts := &helm.Options{
		SetValues: values,
	}

	output, err := helm.RenderTemplateE(t, opts, helmChartPath, releaseName, templates)
	if expectedErrorRegexp != nil {
		if err == nil {
			t.Error("Expected error but didn't happen")
		} else {
			require.Regexp(t, expectedErrorRegexp, err.Error())
		}
		return "", false
	}
	if err != nil {
		t.Error(err)
		return "", false
	}

	return output, true
}

type workerDeploymentTestCase struct {
	ExpectedName           string
	ExpectedCmd            []string
	ExpectedStrategyType   appsV1.DeploymentStrategyType
	ExpectedSelector       *metav1.LabelSelector
	ExpectedLivenessProbe  *coreV1.Probe
	ExpectedReadinessProbe *coreV1.Probe
	ExpectedNodeSelector   map[string]string
	ExpectedTolerations    []coreV1.Toleration
}

type workerDeploymentSelectorTestCase struct {
	ExpectedName     string
	ExpectedSelector *metav1.LabelSelector
}

type deploymentList struct {
	metav1.TypeMeta `json:",inline"`

	Items []appsV1.Deployment `json:"items" protobuf:"bytes,2,rep,name=items"`
}

type deploymentAppsV1List struct {
	metav1.TypeMeta `json:",inline"`

	Items []appsV1.Deployment `json:"items" protobuf:"bytes,2,rep,name=items"`
}

func mergeStringMap(dst, src map[string]string) {
	for k, v := range src {
		dst[k] = v
	}
}

func defaultLivenessProbe() *coreV1.Probe {
	return &coreV1.Probe{
		Handler: coreV1.Handler{
			HTTPGet: &coreV1.HTTPGetAction{
				Path:   "/",
				Port:   intstr.FromInt(5000),
				Scheme: coreV1.URISchemeHTTP,
			},
		},
		InitialDelaySeconds: 15,
		TimeoutSeconds:      15,
	}
}

func defaultReadinessProbe() *coreV1.Probe {
	return &coreV1.Probe{
		Handler: coreV1.Handler{
			HTTPGet: &coreV1.HTTPGetAction{
				Path:   "/",
				Port:   intstr.FromInt(5000),
				Scheme: coreV1.URISchemeHTTP,
			},
		},
		InitialDelaySeconds: 5,
		TimeoutSeconds:      3,
	}
}

func workerLivenessProbe() *coreV1.Probe {
	return &coreV1.Probe{
		Handler: coreV1.Handler{
			HTTPGet: &coreV1.HTTPGetAction{
				Path:   "/worker",
				Port:   intstr.FromInt(5000),
				Scheme: coreV1.URISchemeHTTP,
			},
		},
		InitialDelaySeconds: 0,
		TimeoutSeconds:      0,
	}
}

func workerReadinessProbe() *coreV1.Probe {
	return &coreV1.Probe{
		Handler: coreV1.Handler{
			HTTPGet: &coreV1.HTTPGetAction{
				Path:   "/worker",
				Port:   intstr.FromInt(5000),
				Scheme: coreV1.URISchemeHTTP,
			},
		},
		InitialDelaySeconds: 0,
		TimeoutSeconds:      0,
	}
}
