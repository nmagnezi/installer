package main

import (
	"github.com/spf13/cobra"

	"github.com/openshift/installer/cmd/openshift-install/appliance"
	"github.com/openshift/installer/pkg/asset"
	"github.com/openshift/installer/pkg/asset/agent/agentconfig"
	"github.com/openshift/installer/pkg/asset/agent/image"
	"github.com/openshift/installer/pkg/asset/agent/manifests"
	"github.com/openshift/installer/pkg/asset/agent/mirror"
	"github.com/openshift/installer/pkg/asset/kubeconfig"
	"github.com/openshift/installer/pkg/asset/password"
)

func newApplianceCmd() *cobra.Command {
	applianceCmd := &cobra.Command{
		Use:   "appliance",
		Short: "Commands for supporting cluster installation using an appliance",
		RunE: func(cmd *cobra.Command, args []string) error {
			return cmd.Help()
		},
	}

	applianceCmd.AddCommand(newApplianceCreateCmd())
	applianceCmd.AddCommand(appliance.NewWaitForCmd())
	return applianceCmd
}

var (
	applianceConfigTarget = target{
		// TODO: remove template wording when interactive survey has been implemented
		name: "Agent Config Template",
		command: &cobra.Command{
			Use:   "agent-config-template",
			Short: "Generates a template of the agent config manifest used by the agent installer",
			Args:  cobra.ExactArgs(0),
		},
		assets: []asset.WritableAsset{
			&agentconfig.AgentConfig{},
		},
	}

	applianceManifestsTarget = target{
		name: "Cluster Manifests",
		command: &cobra.Command{
			Use:   "cluster-manifests",
			Short: "Generates the cluster definition manifests used by the agent installer",
			Args:  cobra.ExactArgs(0),
		},
		assets: []asset.WritableAsset{
			&manifests.AgentManifests{},
			&mirror.RegistriesConf{},
			&mirror.CaBundle{},
		},
	}

	applianceImageTarget = target{
		name: "Agent ISO Image",
		command: &cobra.Command{
			Use:   "image",
			Short: "Generates a bootable image containing all the information needed to deploy a cluster",
			Args:  cobra.ExactArgs(0),
		},
		assets: []asset.WritableAsset{
			&image.AgentImage{},
			&kubeconfig.AgentAdminClient{},
			&password.KubeadminPassword{},
		},
	}

	//nolint:varcheck,deadcode
	appliancePXEFilesTarget = target{
		name: "Agent PXE Files",
		command: &cobra.Command{
			Use:   "pxe-files",
			Short: "Generates PXE bootable image files containing all the information needed to deploy a cluster",
			Args:  cobra.ExactArgs(0),
		},
		assets: []asset.WritableAsset{
			&image.AgentPXEFiles{},
			&kubeconfig.AgentAdminClient{},
			&password.KubeadminPassword{},
		},
	}

	applianceTargets = []target{applianceConfigTarget, applianceManifestsTarget, applianceImageTarget}
)

func newApplianceCreateCmd() *cobra.Command {

	cmd := &cobra.Command{
		Use:   "create",
		Short: "Commands for generating an appliance artifacts",
		Args:  cobra.ExactArgs(0),
		RunE: func(cmd *cobra.Command, args []string) error {
			return cmd.Help()
		},
	}

	for _, t := range applianceTargets {
		t.command.Args = cobra.ExactArgs(0)
		t.command.Run = runTargetCmd(t.assets...)
		cmd.AddCommand(t.command)
	}

	return cmd
}
